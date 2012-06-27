package fusinvserv;
use Dancer ':syntax';
use Dancer::Plugin::Mongo;

our $VERSION = '0.1';

sub getConfig {

    my $config = {
        'configValidityPeriod' => 600,
            'schedule' => [
            {
                'periodicity' => 5600,
                'task' => 'Inventory',
                'remote' => uri_for('/input')->as_string()
            }
        ]
    };

    return $config;
}

sub importInventory {
    my ($inventory) = @_;

}

get '/' => sub {

    if (param("action") && (param("action") eq 'getConfig')) {
        halt unless param("machineid");
        return to_json(getConfig(machineid => vars->{param "machineid"}));
    }

    my @sectionList = (
               {
                   title => 'Hostname',
                   mongoKey => 'hardware.name'
               },
               {
                   title => 'MAC addresses',
                   mongoKey => 'networks.macaddr'
               },
               {
                   title => 'Serial Number',
                   mongoKey => 'bios.ssn'
               }
            );

    foreach (@sectionList) {
        $_->{entries} = mongo->database->run_command({
                "distinct" => 'inventory',
                "key"      => $_->{mongoKey},
                "limit"    => 100
                })->{values};
    }

    return template 'list' => {sectionList => \@sectionList}; 

};

post '/input' => sub {
    my $inventory = from_json(request->body());

    halt unless $inventory;
    halt unless param("machineid");

    if (param("action") eq 'setInventory') {
        $inventory->{machineid} = param("machineid");
        $inventory->{imported_date} = time;

        mongo->database->inventory->insert($inventory) or die;
    }

};

get '/show/*/*' => sub {
    my ($key, $value) = splat;

    send_error("Bad Request", 400) unless $key;

    my $result = mongo->database->inventory->find({$key => $value})->sort({ 'imported_date' => 1 });
    
    send_error("Computer not found", 404) if ($result->count() == 0);

    return template 'show' => { inventory => $result->next };
};

true;
