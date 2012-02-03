package org.smart.test;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import org.smart.test.foo.Foo;

public class Foobar extends Activity
{
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        String s = Foo.getName();
        Log.d("smart:", s);
    }
}
