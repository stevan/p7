
use v5.40;
use experimental qw[ class builtin ];
use builtin      qw[ load_module ];

class module {
    sub import ($module, @to_load) {
        state %added_to_INC;
        state %modules_loaded;

        if ($module ne __PACKAGE__) {
            my $mod_path = $module =~ s/\:\:/\//gr;
            foreach my $to_load ( @to_load ) {

                my $class_path = $to_load =~ s/\:\:/\//gr;
                $class_path .= '.pm';
                #warn ">>> modpath($mod_path) classpath($class_path)";

                next if $INC{$class_path};
                #warn ">>> classpath($class_path) is not in INC";

                next if $INC{join '/' => $mod_path, $class_path};
                #warn ">>> modpath($mod_path) + classpath($class_path) is not in INC";

                my $resolved = $module->resolve( $to_load );
                #warn "$module ... resolved($resolved)";
                unless (exists $modules_loaded{ $resolved }) {
                    #warn "$module loading resolved($resolved)";
                    load_module( $resolved );
                    $modules_loaded{ $resolved }++;
                }
                else {
                    #warn "$module resolved($resolved) is already loaded";
                }
            }
        }
        else {
            my ($from, $file) = caller();
            #warn "module($module) from($from) file($file) to_load(",(join ', ' => @to_load),")";
            my ($root, $path) = ($file =~ /^(.*)(\/org\/.*)\.pm$/);
            my @path      = split /\// => $path;
            my @namespace = grep /^[a-z][a-z0-9]+$/, @path;
            my $INC_path  = join '/' => $root, @namespace;
            unless (exists $added_to_INC{ $INC_path }) {
                #warn "adding path($INC_path) to INC";
                push @INC => $INC_path;
                $added_to_INC{ $INC_path }++;
            }
            else {
                #warn "path($INC_path) was already in INC";
            }
        }
    }

    sub resolve ($module, $class) {
        join '::' => $module, $class
    }
}
