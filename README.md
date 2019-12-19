This Perl script serves as a bridge between an Asterisk server and the Zammad CTI interface. It connects via AMI to Asterisk and monitors it for queue events; the relevant ones will be pushed to Zammad's CTI interface.

# Limitations

- No AMI SSL support yet, so use it only on the Asterisk host.
- Can only monitor queue events and nothing else.

# Setup

1. Enable AMI in Asterisk in `/etc/asterisk/manager.conf`.

2. Create the file `/etc/asterisk/manager.d/zammad.conf` with the following contents:

    ```
    [zammad]
    secret = xxx
    read = agent
    ```

    Use a strong randomly generated password, e.g. `$(pwgen 32)`.

3. Run `manager reload` in `asterisk -r`.

4. Install the Perl dependencies listed in the script.

    E.g. on Debian stretch:

    ```
    apt install libanyevent-http-perl libconfig-simple-perl libdata-printer-perl liblog-any-perl liblog-any-adapter-dispatch-perl libwww-form-urlencoded-perl
    cpan Asterisk::AMI
    ```

5. Enable Zammad's CTI (Generic) interface.

6. Copy `config.cfg.sample` to `config.cfg`:

    ```
    cp config.cfg.sample config.cfg
    chmod 600 config.cfg
    ```

7. Edit `config.cfg` and fill in your Zammad CTI URL and your AMI secret.

8. Start the script:

    ```
    ./asterisk-zammad-cti-bridge
    ```

# systemd

An example systemd service file `asterisk-zammad-cti-bridge.service.example` is provided. To install it:

1. Copy the file to `/etc/systemd/system` and remove the `.example`:

    ```
    cp -a asterisk-zammad-cti-bridge.service.example /etc/systemd/system/asterisk-zammad-cti-bridge.service
    ```

2. Create the required user:

    ```
    useradd asterisk-zammad-cti-bridge
    ```

3. Set the `config.cfg` permissions:

    ```
    chown asterisk-zammad-cti-bridge config.cfg
    chmod 0600 config.cfg
    ```

    `asterisk-zammad-cti-bridge` will read `config.cfg` from the current working directory or from the application directory, so you can place it either in `/home/asterisk-zammad-cti-bridge` or in `/opt/asterisk-zammad-cti-bridge`.

4. Adapt the service file to your requirements:

    - Change `ExecStart` to the correct path where you've placed `asterisk-zammad-cti-bridge.service`. The service defaults to `/opt/asterisk-zammad-cti-bridge`.

    - If you want to use different Asterisk/Zammad instances from the config (see "Multiple instances" below), edit the service file as necessary. Create one systemd service file for each `asterisk-zammad-cti-bridge.service` instance.

5. Enable the service:

    ```
    systemctl enable asterisk-zammad-cti-bridge.service
    ```

6. Start the service:

    ```
    systemctl start asterisk-zammad-cti-bridge.service
    ```

# Multiple instances

If you want to bridge multiple Asterisk/Zammad instances, e.g. one Asterisk to two Zammad instances (prod and test), you need to run multiple `asterisk-zammad-cti-bridge` instances. Add a new section to `config.cfg` for each additional instance, e.g.:

```
[zammad-test]
url=https://zammad-test.example.com/api/v1/cti/mytoken
```

Then start a new `asterisk-zammad-cti-bridge` instance and tell it to read the `[zammad-test]` section instead of the `[zammad]` section:

```
./asterisk-zammad-cti-bridge --zammad zammad-test
```


# Asterisk Config

If you have not configured queues in asterisk before the following would be enough to get going:

Add the following to  extensions.conf (Adapt to your environment)

[support]
exten => 1000,1,Answer
exten => 1000,2,Ringing
exten => 1000,3,Wait(2)
exten => 1000,4,Queue(support)
exten => 1000,6,Hangup

Add the following to queues.conf (make sure to replace SIP/XXXX with your actual device/phone)

[support]
music=default
strategy=ringall
timeout=15
retry=1
wrapuptime=0
maxlen = 0
announce-frequency = 0
announce-holdtime = no

member => SIP/XXXX
member => SIP/XXXX

