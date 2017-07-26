from fabric.api import run, env, sudo, cd, prefix, shell_env

env.hosts = ['45.76.233.87']
env.user = 'ryan'

DIR = '/home/ryan/goatfinder/GOATFinder'
VENV = 'source SECRETS.ENV'

def start ():
  with cd(DIR):
    with shell_env(PATH='/home/ryan/.nvm/versions/node/v6.10.3/bin:$PATH'):
      with prefix(VENV):
        run('pm2 start index.js > start.log')

def stop ():
  run('pm2 stop all > stop.log')

def deploy ():
  with cd(DIR):
    run('git pull')

    with prefix(VENV):
      run('npm install  > install.log')

    run('pm2 restart all > restart.log')
