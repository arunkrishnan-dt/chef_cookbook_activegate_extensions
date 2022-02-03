default['extension_repo'] = "https://dt-cdn.net/hub/extensions"
default['activegate']['extension_dir'] = '/opt/dynatrace/remotepluginmodule/plugin_deployment'
default['activegate']['tmp_dir'] = '/var/tmp'

default['dynatrace']['tenancy_url'] = "https://xzv52984.live.dynatrace.com"
default['tenancy']['uid'] = 'xzv52984'

default['extensions'] = {
    'ibmmq_java' => { 
        'version' => '2.020.10',
        'os' => ''
    },
    'mssql' => {
        'version' => '2.28',
        'os' => '.linux'
    },
    'db2'   => {
        'version' => '1.2.23',
        'os' => '.linux'
    },
    'datapowerxml'   => {
        'version' => '1.107',
        'os' => ''
    }
}