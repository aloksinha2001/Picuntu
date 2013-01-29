package net.g8.picuntu.activities;

import net.g8.picuntu.R;
import net.g8.picuntu.config.WanSchema;
import android.app.Activity;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.EditText;

/**
 * Activity to collect URL of installation files from Internet.
 * @author linuxerwang@gmail.com
 */
public class WanActivity extends BaseActivity {
  private final TextWatcher textWatcher = new TextWatcher() {
    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {}

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

    @Override
    public void afterTextChanged(Editable s) {
      maybeEnableNextButton();
    }
  };


  private WanSchema wanSchema;
  private EditText urlInput;


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState, R.layout.activity_wan);

    wanSchema = (WanSchema) installConfig.getInstallSchema();

    urlInput = (EditText) findViewById(R.id.urlInput);
    urlInput.setText(wanSchema.getUrl());
    urlInput.addTextChangedListener(textWatcher);
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
    wanSchema.setUrl(urlInput.getText().toString());
    return KernelActivity.class;
  }
}
