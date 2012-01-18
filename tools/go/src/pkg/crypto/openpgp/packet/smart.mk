#
$(call go-new-module, crypto/openpgp/packet, pkg)

GOFILES=\
	compressed.go\
	encrypted_key.go\
	literal.go\
	one_pass_signature.go\
	packet.go\
	private_key.go\
	public_key.go\
	reader.go\
	signature.go\
	symmetrically_encrypted.go\
	symmetric_key_encrypted.go\
	userid.go\

sm.this.sources := $(GOFILES)
sm.this.depends +=\
  goal-crypto\
  goal-crypto/openpgp/errors\
  goal-crypto/openpgp/elgamal\
  goal-crypto/openpgp/s2k\
  goal-compress/zlib\

$(go-build-this)
