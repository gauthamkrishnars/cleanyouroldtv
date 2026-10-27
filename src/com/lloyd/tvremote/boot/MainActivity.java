package com.lloyd.tvremote.boot;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Toast;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        new Thread(new Runnable() {
            @Override
            public void run() {
                BootReceiver.startServerAsRoot();
            }
        }).start();
        Toast.makeText(this, "Starting TV Remote Server...", Toast.LENGTH_SHORT).show();
        finish();
    }
}
