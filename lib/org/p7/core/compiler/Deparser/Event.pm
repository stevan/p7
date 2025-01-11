
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::core::compiler ];

use org::p7::core::util qw[ Logging ];

class Deparser::Event {
    use overload '""' => 'to_string';

    field $op :param :reader;

    field $type :reader;
    ADJUST {
        $type = __CLASS__ =~ s/^Deparser\:\:Event\:\://r;
    }

    method has_compliment { true }

    method is_enter   { !!(__CLASS__ =~ m/\:\:Enter/) }
    method is_leave   { !!(__CLASS__ =~ m/\:\:Leave/) }

    method compliment {
        return __CLASS__ =~ s/\:\:Enter/\:\:Leave/r if $self->is_enter;
        return __CLASS__ =~ s/\:\:Leave/\:\:Enter/r if $self->is_leave;
    }

    method create_compliment { $self->compliment->new( op => $op ) }

    method to_string {
        sprintf "%s( %s @ %d )" =>
            $type,
            $op->to_string,
            $op->depth;
    }
}

class Deparser::Event::EnterSubroutine :isa(Deparser::Event) {}
class Deparser::Event::LeaveSubroutine :isa(Deparser::Event) {}

class Deparser::Event::EnterPreamble :isa(Deparser::Event) {}
class Deparser::Event::LeavePreamble :isa(Deparser::Event) {}

class Deparser::Event::EnterStatementSequence :isa(Deparser::Event) {}
class Deparser::Event::LeaveStatementSequence :isa(Deparser::Event) {}

class Deparser::Event::EnterStatement :isa(Deparser::Event) {}
class Deparser::Event::LeaveStatement :isa(Deparser::Event) {}

class Deparser::Event::EnterExpression :isa(Deparser::Event) {}
class Deparser::Event::LeaveExpression :isa(Deparser::Event) {}

class Deparser::Event::Terminal :isa(Deparser::Event) {
    method has_compliment { false }
    method compliment { __CLASS__ }
}
