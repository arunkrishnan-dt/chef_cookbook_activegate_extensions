default['download_repo'] = 'https://dt-cdn.net/hub/extensions'
default['activegate']['extension_dir'] = '/opt/dynatrace/remotepluginmodule/plugin_deployment'
default['activegate']['tmp_dir'] = '/var/tmp'

# default values
default['extension']['name'] = 'ibmmq_j'
default['extension']['version'] = '2.0.0'
default['extension']['os'] = 'linux'

default['extensions'] = {
    'ibmmq_java' => { 
        'version' => '2.020.10',
        'os' => ''
    },
    'mssql' => {
        'version' => '2.28',
        'os' => '.linux'
    }
}