
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::core::compiler ];

use org::p7::core::util qw[ Logging ];

class Deparser::Tree::Builder :isa(Deparser::Observer) {

    field @stack        :reader;
    field $error        :reader;
    field $result       :reader;
    field $is_completed :reader = false;

    method has_error  { defined $error  }
    method has_result { defined $result }

    method build {
        die "Cannot call build if there has been an error"
            if $error;
        die "Cannot call build on an uncompleted tree"
            unless $is_completed;
        return $result;
    }

    method on_next ($e) {
        DEBUG && LOG $self, sprintf '%s- %s' => ('  ' x $e->op->depth), $e->to_string;
        #return;
        return if $error || $is_completed;

        if (DEBUG) {
            LOG $self, '== >TREE ==============================';
            LOG $self, "GOT: $e";
            LOG $self, "-- BEFORE -----------------------------";
            LOG $self, "  - ".join "\n  - " => map $_->node, @stack;
        }

        if ($e isa Deparser::Event::EnterSubroutine        ||
            $e isa Deparser::Event::EnterPreamble          ||
            $e isa Deparser::Event::EnterStatementSequence ||
            $e isa Deparser::Event::EnterStatement         ||
            $e isa Deparser::Event::EnterExpression        ||
            $e isa Deparser::Event::Terminal               ){
            push @stack => Deparser::Tree->new( node => $e );
        }
        elsif ($e isa Deparser::Event::LeaveExpression        ||
               $e isa Deparser::Event::LeaveStatement         ||
               $e isa Deparser::Event::LeaveStatementSequence ||
               $e isa Deparser::Event::LeavePreamble          ||
               $e isa Deparser::Event::LeaveSubroutine        ){
            my @children = $self->collect_children( $e );
            $stack[-1]->add_children( @children );
        }

        if (DEBUG) {
            LOG $self, "-- AFTER ------------------------------";
            LOG $self, "  - ".join "\n  - " => map $_->node, @stack;
            LOG $self, '== <TREE ==============================';
        }
    }

    method on_completed {
        $is_completed = true;
        $result = $stack[0];
    }

    method on_error ($e) {
        $is_completed = true;
        $error = $e
    }

    method collect_children ($e) {
        my @children;
        while (@stack) {
            last if $stack[-1]->node->op->addr == $e->op->addr;
            push @children => pop @stack;
        }
        return reverse @children;
    }
}


