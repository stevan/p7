
use v5.40;
use experimental qw[ class ];

class org::p7::util::function :isa(module) {
    sub resolve ($module, $class) {
        $class =~ s/^Bi//;
        join '::' => $module, $class
    }
}
