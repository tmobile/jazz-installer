import subprocess
import sys

install_logfile = 'install.log'


def call(args, workdir=None):
    with open(install_logfile, 'a') as output:
        output.write('Invoking command: {0}\n'.format(' '.join(args)))
        output.flush()  # Flush to make sure order is maintained
        subprocess.call(args, stderr=output, stdout=output, cwd=workdir)


def check_call(args, workdir=None):
    with open(install_logfile, 'a') as output:
        output.write('Invoking command: {0}\n'.format(' '.join(args)))
        output.flush()  # Flush to make sure order is maintained
        subprocess.check_call(args, stderr=output, stdout=output, cwd=workdir)


def check_output(args, workdir=None):
    with open(install_logfile, 'a') as output:
        output.write('Invoking command: {0}\n'.format(' '.join(args)))
        output.flush()  # Flush to make sure order is maintained
        return subprocess.check_output(args, stderr=output, cwd=workdir)


def tee_check_output(args, workdir=None):
    with open(install_logfile, 'a') as output:
        output.write('Invoking command: {0}\n'.format(' '.join(args)))
        output.flush()  # Flush to make sure order is maintained
        p = subprocess.Popen(args, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, bufsize=1, cwd=workdir)
        while p.poll() is None:
            for line in p.stdout:
                sys.stdout.buffer.write(line)
                output.write(line.decode('utf8'))
        return p.returncode == 0
