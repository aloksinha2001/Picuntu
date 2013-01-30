package net.g8.picuntu.activities;


import java.io.DataOutputStream;
import java.io.IOException;

import net.g8.picuntu.R;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

/**
 * The entry activity to Picuntu Installer.
 * @author linuxerwang@gmail.com
 */
public class MainActivity extends BaseActivity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState, R.layout.activity_main);

    Button exitButton = (Button) findViewById(R.id.exitButton);
    exitButton.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.addCategory(Intent.CATEGORY_HOME);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
      }
    });

    // Gain superuser permission.
    boolean suGained = false;
    try {
      Process process = Runtime.getRuntime().exec("su");
      DataOutputStream outputStream = new DataOutputStream(process.getOutputStream());

      outputStream.writeBytes("exit\n");
      outputStream.flush();
      process.waitFor();
      suGained = true;
    } catch (IOException ignored) {
    } catch (InterruptedException ignored) {
    }

    TextView welcomeMessage = (TextView) findViewById(R.id.welcomeMessage);
    if (suGained) {
      welcomeMessage.append("\n\nGood. You device is already rooted!" +
      		" You can go on install Picuntu.");
    } else {
      welcomeMessage.append("\n\nYou device has not been rooted! Installation is not possible." +
      		" Exit now!");
      nextButton.setEnabled(false);
    }
	}


  @Override
  protected Class<? extends Activity> getNextActivity() {
    return SourceActivity.class;
  }
}
