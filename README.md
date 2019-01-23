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
    ```

7. Edit `config.cfg` and fill in your Zammad CTI URL and your AMI secret.

8. Start the script:

    ```
    ./asterisk-zammad-cti-bridge
    ```
