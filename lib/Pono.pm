use v5.42;
use utf8;
use experimental qw(class);

class Pono 0.01 :isa(Pono::Base) {
    use Pono::Router::Linear;
    use Carp ();

    sub import($class) {
        $_->import for qw(strict warnings utf8);

        feature->import(':5.42');
        builtin->import(':5.42');
        experimental->import('class');
    }

    ADJUST {
        if (!$self->router) {
            $self->router(Pono::Router::Linear->new);
        }

        Carp::croak 'router must be a Pono::Router subclass' unless $self->router isa Pono::Router;
    }
}

__END__

=encoding utf-8

=head1 NAME

Pono - It's new $module

=head1 SYNOPSIS

    use Pono;

    my $app = Pono->new;
    $app->get('/', sub ($c) {
        $c->text(HTTP_OK, 'Hello Pono!')
    });

    $app->psgi;

=head1 DESCRIPTION

Pono is ...

=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kentafly88@gmail.comE<gt>

=cut

