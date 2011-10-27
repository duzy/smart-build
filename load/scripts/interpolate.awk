#!/usr/bin/awk -f
#
#  interpolate.awk - Rewrite input stream according to a set of variables.
#
#  For the input text, do these if variable FOOBAR exists with value "foobar":
#    1) replace "#undef FOOBAR" with "#define FOOBAR foobar"
#    2) replace "@FOOBAR@" with "foobar"
#
#  Usage:
#  
#    awk -f interpolate.awk -vars 'VAR1=foo;VAR2=bar' foobar.in
#
BEGIN {
    opts["LineBased"] = 1
    opts["Header"] = 0
    
    for (argn = 0; argn < ARGC; ++argn) {
        if (ARGV[argn] == "-header") {
            opts["Header"] = 1
            delete ARGV[argn]
        }
        if (ARGV[argn] == "-vars") {
            vars_string = ARGV[argn + 1]
            delete ARGV[argn]
            delete ARGV[argn + 1]
        }
    }

    if (vars_string) {
        parse_command_line_vars(vars_string)
    }

    if (opts["LineBased"]) {
        FS = "";   # treat each line as one field
        RS = "\n"; #
    }
}

#
#  Configure string is in such format:
#       NAME1 = value ; NAME2 = value ; NAME3 = foo \; bar ; NAME4 = value
#
function parse_command_line_vars(vars_string)
{
    #printf("vars: %s\n", vars_string)

    while (0 < (n = index(vars_string, "="))) {
        var_name = substr(vars_string, 0, n - 1)
        vars_string = substr(vars_string, n + 1)

        ## strip beginning and ending spaces
        gsub(/[[:space:]]+$/, "", var_name)
        gsub(/^[[:space:]]+/, "", var_name)

        n = index(vars_string, ";")
        if (n == 0) {
            ## the last config item is EMPTY
            #printf("last-var: %d: %s=%s\n", n, var_name, vars_string)

            var_value = substr(vars_string, n)
            gsub(/^[[:space:]]+/, "", var_value) # remove leading spaces
            #gsub(/[[:space:]]+$/, "", var_value) # remove tailing spaces
            while (sub("\\\\;",  ";", var_value)) {} # replace "\;" with ";"
            while (sub("\\\\n", "\n", var_value)) {} # replace "\n" with newline

            vars[var_name] = var_value
            continue
        }

        while (substr(vars_string, n - 1, 2) == "\\;") {
            if (nn = index(substr(vars_string, n + 1), ";"))
            {
                n += nn
                #printf("test: %d, %d\n", n, nn)
            } else {
                n = length(vars_string) + 1
                break
            }
        }

        var_value = substr(vars_string, 0, n - 1)
        gsub(/^[[:space:]]+/, "", var_value) # remove leading spaces
        #gsub(/[[:space:]]+$/, "", var_value) # remove tailing spaces
        while (sub("\\\\;",  ";", var_value)) {} # replace "\;" with ";"
        while (sub("\\\\n", "\n", var_value)) {} # replace "\n" with newline

        #printf("var: %d: %s=%s\n", n, var_name, var_value) > "/dev/stderr"
        vars[var_name] = var_value

        if (length(vars_string) <= n) {
            break
        } else {
            vars_string = substr(vars_string, n + 1)
        }
    }

    vars_string = var_name = var_value = ""
}

#
#  Process basing on the default FS, RS values.
#
function default_record_based_processing()
{
    if ($1 == "#undef") {
        if (vars[$2]) {
            printf("#define %s %s\n", $2, vars[$2])
        } else {
            printf("/* %s */\n", $0)
        }
    } else {
        print
    }
}

#
# Process basing on line-by-line input.
# 
function line_record_based_processing()
{
    # /@([^@[:space:]]+)@/
    while (match($0, /@([A-Za-z0-9_]+)@/, arr)) {
        var_name = arr[1]
        if (var_name in vars) {
            var_value = vars[var_name]
            gsub(/^[[:space:]]*"/, "", var_value)
            gsub(/"[[:space:]]*$/, "", var_value)
            $0 = substr($0, 0, RSTART-1) var_value substr($0, RSTART+RLENGTH)
        } else {
            printf(FILENAME ":" NR ": \"" var_name "\" is undefined\n") > "/dev/stderr"
            exit(-1)
        }
    }

    if (opts["Header"]) {
        if (match($0, /([[:space:]]*)#([[:space:]]*)undef[[:space:]]+([[:alnum:]_]+)/, arr)) {
            def_space0 = arr[1]
            def_space1 = arr[2]
            def_name = arr[3]
            if (def_name in vars) {
                def_value = vars[def_name]
                if (def_value == "#undef") {
                    $0 = "/* " $0 " */"
                } else {
                    $0 = def_space0 "#" def_space1 "define " def_name " " def_value
                }
            }
        }
    }

    print
}

# for each record:
{
    if (opts["LineBased"]) {
        line_record_based_processing()
    } else {
        default_record_based_processing()
    }
}
