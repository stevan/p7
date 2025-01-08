
use v5.40;
use experimental qw[ class builtin ];
use builtin      qw[ load_module ];

class module {
    sub import ($class, @to_load) {
        if ($class ne __PACKAGE__) {
            foreach my $to_load ( @to_load ) {
                load_module(join '::' => $class, $to_load);
            }
        }
        else {
            my ($from, $file) = caller();
            #warn "class($class) from($from) file($file) to_load(",(join ', ' => @to_load),")";
        }
    }
}
