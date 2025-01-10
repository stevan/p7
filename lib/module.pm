
use v5.40;
use experimental qw[ class builtin ];
use builtin      qw[ load_module ];

class module {
    sub import ($module, @to_load) {
        state %added_to_INC;
        state %modules_loaded;

        #my ($from, $file) = caller();
        #warn sprintf "module: %30s ( %30s ) from file: %50s \n",
        #    $module,
        #    (join ', ' => @to_load),
        #    $file,
        #;

        #warn "BEFORE:\n  -",(join "\n  -" => grep !/^\//, @INC),"\n";

        if ($module ne __PACKAGE__) {
            my $mod_path = $module =~ s/\:\:/\//gr;
            foreach my $to_load ( @to_load ) {
                my $class_path = $to_load =~ s/\:\:/\//gr;
                $class_path .= '.pm';
                #warn ">>> modpath($mod_path) classpath($class_path)";
                if (exists $INC{$class_path} || exists $INC{join '/' => $mod_path, $class_path}){
                    #warn ">>> modpath($mod_path) +| classpath($class_path) is not in INC";
                    $to_load->import() if $to_load->can('import');
                    next;
                }
                my $resolved = $module->resolve( $to_load );
                #warn "$module ... resolved($resolved)";
                unless (exists $modules_loaded{ $resolved }) {
                    #warn "$module loading resolved($resolved)";
                    load_module( $resolved );
                    # XXX:
                    # this might not always work because
                    # it should probably re-fire on each
                    # import, but we are only doing it once
                    if ($to_load->can('import')) {
                        $to_load->import();
                    }
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

        #warn "AFTER:\n  -",(join "\n  -" => grep !/^\//, @INC),"\n";
    }

    sub resolve ($module, $class) {
        join '::' => $module, $class
    }
}
