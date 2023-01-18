This Perl script serves as a bridge between an Asterisk server and the Zammad CTI interface. It connects via AMI to Asterisk and monitors it for queue events; the relevant ones will be pushed to Zammad's CTI interface.

# Limitations

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

4. Enable Zammad's CTI (Generic) interface.

5. Rename `config.cfg.sample` to `config.cfg`. Edit and fill in your Zammad CTI URL and your AMI secret.

6. Build and start the container:

    ```
    docker-compose up --build -d
    ```

7. Check the logs and troubleshoot:

    ```
    docker-compose logs -f
    ```
# Multiple Instances
Add config.cfg sections and edit the entrypoint of the Dockerfile accordingly to load them.
