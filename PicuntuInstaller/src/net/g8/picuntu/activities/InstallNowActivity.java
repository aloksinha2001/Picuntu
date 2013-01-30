package net.g8.picuntu.activities;

import java.io.DataOutputStream;
import java.io.File;
import java.io.IOException;
import java.util.Scanner;

import net.g8.picuntu.R;
import net.g8.picuntu.config.KernelConfig;
import net.g8.picuntu.config.RootfsConfig;
import net.g8.picuntu.config.SdSchema;
import android.app.Activity;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.widget.TextView;

/**
 * Activity to show the real installation process.
 * @author linuxerwang@gmail.com
 */
public class InstallNowActivity extends BaseActivity {
  private class InstallException extends Exception {
    public InstallException(String message) {
      super(message);
    }

    public InstallException(Throwable cause) {
      super(cause);
    }
  }

  private static final String TEMP_DIR = "/sdcard/install_files";
  private static final String CREATE_TEMP_DIR_CMD = String.format(
      "mkdir -p %s\n", TEMP_DIR);

  private static final String COPY_CMD = "cp %s/%s %s/\n";
  private static final String DOWNLOAD_CMD = "busybox wget %s/%s -P %s\n";
  private static final String MD5SUM_CHECK_CMD = "busybox md5sum -c %s/%s.md5\n";

  private static final String KERNEL_INSTALL_CMD =
      "busybox dd if=%s/kernel.img of=/dev/block/mtd/by-name/%s bs=8192\n";
  private static final String KERNEL_COPYBACK_CMD =
      "busybox dd if=/dev/block/mtd/by-name/%s of=%s/kernel-new.img bs=8192 count=%s\n";
  private static final String VERIFY_KERNEL_CMD =
      "busybox diff %s/kernel-new.img %s/kernel.img\n";

  private static final String UMOUNT_CARD_CMD = "umount %s\n";
  private static final String CREATE_PARTITION_CMD = "busybox fdisk %s\n";
  private static final String FDISK_DELETE_PARTITION_COMMANDS = "d\n4\nd\n3\nd\n2\nd\n1\n";
  private static final String FDISK_CREATE_PARTITION_COMMANDS =
      "u\nn\np\n3\n\n2047\n" + // Create the reserve partition.
      "n\np\n1\n\n+63M\n" + // Create partition 1 of 63M size.
      "n\np\n2\n\n\n" + // Create partition 2 with all remaining space.
      "d\n3\nt\nl\nb\n" + // Delete the reserve partition
      "w\n"; // Exit.
  private static final String CREATE_FS_PARTITION = "mke2fs -L linuxroot -t ext4 %s\n";
  private static final String CREATE_MOUNT_DIR_CMD = "mkdir -p /data/picuntu\n";
  private static final String MOUNT_LINUXROOT_DIR_CMD = "mount %s /data/picuntu\n";
  private static final String UMOUNT_LINUXROOT_DIR_CMD = "umount /data/picuntu\n";
  private static final String ROOTFS_INSTALL_CMD =
      "busybox tar -xvzf %s/rootfs.tar.gz /data/picuntu/\n";

  private KernelConfig kernelConfig;
  private RootfsConfig rootfsConfig;

  private TextView progressView;
  String sourcePrefix;
  PicuntuInstallationTask asyncTask = new PicuntuInstallationTask();

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState, R.layout.activity_install_now);

    kernelConfig = installConfig.getInstallSchema().getKernelConfig();
    rootfsConfig = installConfig.getInstallSchema().getRootfsConfig();
    sourcePrefix = installConfig.getInstallSchema().getPrefix();

    progressView = (TextView) findViewById(R.id.installProgress);
    progressView.setMovementMethod(new ScrollingMovementMethod());

    asyncTask.execute();
  }


  @Override
  protected Class<? extends Activity> getNextActivity() {
    return SuccessActivity.class;
  }


  private class PicuntuInstallationTask extends AsyncTask<Void, String, Void> {
    public void logMessage(String message) {
      publishProgress(message);
    }

    @Override
    protected Void doInBackground(Void... params) {
      try {
        prepareInstallDir();
        installKernel();
        installRoofs();
      } catch (Exception e) {
        publishProgress(e.getMessage());
      }

      return null;
    }

    @Override
    protected void onProgressUpdate(String... progresses) {
      for (String progress : progresses) {
        progressView.append("\n");
        progressView.append(progress);
        progressView.append("\n");
      }
    }

    @Override
    protected void onPostExecute(Void result) {
      asyncTask.logMessage("DONE!");
    }
  }


  private String execute(String command) throws InstallException {
    return execute(command, null, false);
  }


  private String execute(String command, boolean changeCWD) throws InstallException {
    return execute(command, null, changeCWD);
  }


  private String execute(String command, String subCommands, boolean changeCWD)
      throws InstallException {
    asyncTask.logMessage(command);

    StringBuilder output = new StringBuilder();
    try {
      Process process;
      if (changeCWD) {
        process = Runtime.getRuntime().exec("su", null, new File(TEMP_DIR));
      } else {
        process = Runtime.getRuntime().exec("su");
      }

      DataOutputStream outputStream = new DataOutputStream(process.getOutputStream());
      outputStream.writeBytes(command);
      outputStream.flush();
      if (subCommands != null && !subCommands.isEmpty()) {
        outputStream.writeBytes(subCommands);
        outputStream.flush();
      }
      outputStream.writeBytes("exit\n");
      outputStream.flush();
      outputStream.close();

      Scanner scanner = new Scanner(process.getInputStream());
      String line = null;
      while (scanner.hasNext()) {
        line = scanner.nextLine();
        asyncTask.logMessage(line);
        output.append(line);
        output.append("\n");
      }

      scanner = new Scanner(process.getErrorStream());
      line = null;
      while (scanner.hasNext()) {
        line = scanner.nextLine();
        asyncTask.logMessage(line);
        output.append(line);
        output.append("\n");
      }

      int exitValue = process.waitFor();
      if (exitValue != 0) {
        throw new InstallException("Command failed!");
      }
    } catch (IOException e) {
      throw new InstallException(e);
    } catch (InterruptedException e) {
      throw new InstallException(e);
    }

    return output.toString();
  }


  private void prepareInstallDir() throws InstallException {
    execute(CREATE_TEMP_DIR_CMD);
  }


  private void verifyFile(String filename) throws InstallException {
    // Check if installation files are correct.
    String kernelMd5sumCommand = String.format(MD5SUM_CHECK_CMD, TEMP_DIR, filename);
    String output = execute(kernelMd5sumCommand, true);
  }


  private void downloadAndVerify(String filename) throws InstallException {
    if (installConfig.getInstallSchema() instanceof SdSchema) {
      String kernelCopyCommand = String.format(COPY_CMD, sourcePrefix, filename, TEMP_DIR);
      execute(kernelCopyCommand, true);
      kernelCopyCommand = String.format(COPY_CMD, sourcePrefix, filename + ".md5", TEMP_DIR);
      execute(kernelCopyCommand, true);
    } else {
      String kernelCopyCommand = String.format(DOWNLOAD_CMD, sourcePrefix, filename, TEMP_DIR);
      execute(kernelCopyCommand, true);
      kernelCopyCommand = String.format(DOWNLOAD_CMD, sourcePrefix, filename + ".md5", TEMP_DIR);
      execute(kernelCopyCommand, true);
    }
    verifyFile(filename);
  }


  private void installKernel() throws InstallException {
    if (kernelConfig.getDestination() == KernelConfig.Destination.IGNORE) {
      return;
    }

    downloadAndVerify("kernel.img");

    long count = new File(TEMP_DIR, "kernel.img").length() / 8192;

    String target = "recovery";
    if (kernelConfig.getDestination() == KernelConfig.Destination.KERNEL) {
      target = "kernel";
    }

    for (int i = 0; i < 10; i++) {
      String output = "";

      try {
        // Flash kernel image.
        String kernelInstallCommand = String.format(KERNEL_INSTALL_CMD, TEMP_DIR, target);
        execute(kernelInstallCommand, true);

        // Copy back for verification.
        String kernelCopyBackCommand = String.format(KERNEL_COPYBACK_CMD, target, TEMP_DIR, count);
        execute(kernelCopyBackCommand, true);

        // Verify.
        String verifyKernelCommand = String.format(VERIFY_KERNEL_CMD, TEMP_DIR, TEMP_DIR);
        output = execute(verifyKernelCommand, true);
      } catch (Exception ignored) {
        output = "differ";
      }
      if (output.toLowerCase().contains("differ")) {
        if (i > 9) {
          throw new InstallException("Install kernel failed 3 times.");
        }
      } else {
        break;
      }
    }
  }


  private void installRoofs() throws InstallException {
    if (rootfsConfig.getDestination() == RootfsConfig.Destination.IGNORE) {
      return;
    }

    // Create partition on external SD card.
    downloadAndVerify("rootfs.tar.gz");

    long count = new File(TEMP_DIR, "kernel.img").length() / 8192;

    String targetPath = "/mnt/external_sd";
    String targetDev = "/dev/block/mmcblk0";
    if (rootfsConfig.getDestination() == RootfsConfig.Destination.INTERNAL_SD) {
      targetPath = "/sdcard";
      targetDev = "";
    }

    // Umount card.
    try {
      execute(String.format(UMOUNT_CARD_CMD, targetPath));
    } catch (Exception ignored) {
    }

    // Create partition.
    execute(String.format(CREATE_PARTITION_CMD, targetDev),
        FDISK_DELETE_PARTITION_COMMANDS + FDISK_CREATE_PARTITION_COMMANDS, false);

    // Create file system.
    execute(String.format(CREATE_FS_PARTITION, targetDev));

    // Mount the linuxroot partition.
    execute(CREATE_MOUNT_DIR_CMD);
    try {
      execute(String.format(UMOUNT_LINUXROOT_DIR_CMD));
    } catch (Exception ignored) {
    }
    execute(String.format(MOUNT_LINUXROOT_DIR_CMD, targetDev));

    // Extract rootfs.
    String rootfsInstallCommand = String.format(ROOTFS_INSTALL_CMD, TEMP_DIR);
    execute(rootfsInstallCommand);
    try {
      execute(String.format(UMOUNT_LINUXROOT_DIR_CMD));
    } catch (Exception ignored) {
    }
  }
}
