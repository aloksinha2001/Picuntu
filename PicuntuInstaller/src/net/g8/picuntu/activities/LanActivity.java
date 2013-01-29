package net.g8.picuntu.activities;

import net.g8.picuntu.R;
import net.g8.picuntu.config.LanSchema;
import android.app.Activity;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.EditText;

/**
 * Activity to collect URL of installation files from local network.
 * @author linuxerwang@gmail.com
 */
public class LanActivity extends BaseActivity {

  private final TextWatcher textWatcher = new TextWatcher() {
    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
    }

    @Override
    public void afterTextChanged(Editable s) {
      maybeEnableNextButton();
    }
  };


  private LanSchema lanSchema;
  private EditText urlInput;


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState, R.layout.activity_lan);

    lanSchema = (LanSchema) installConfig.getInstallSchema();

    urlInput = (EditText) findViewById(R.id.urlInput);
    urlInput.setText(lanSchema.getUrl());
    urlInput.addTextChangedListener(textWatcher);

    maybeEnableNextButton();
  }


  private void maybeEnableNextButton() {
    if (urlInput.getText().toString().length() > 7) {
      nextButton.setEnabled(true);
    } else {
      nextButton.setEnabled(false);
    }
  }


  @Override
  protected Class<? extends Activity> getNextActivity() {
    lanSchema.setUrl(urlInput.getText().toString());
    return KernelActivity.class;
  }
}
