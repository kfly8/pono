#requires 'perl', '5.008001';

requires 'WWW::Form::UrlEncoded';
recommends 'WWW::Form::UrlEncoded::XS';

requires 'Cpanel::JSON::XS';
requires 'Encode';
requires 'HTTP::Entity::Parser';
requires 'HTTP::Headers::Fast';
requires 'Hash::MultiValue';

requires 'HTTP::Parser';
recommends 'HTTP::Parser::XS';

on 'test' => sub {
    requires 'Test2::V0';
    requires 'Unicode::GCString';
    requires 'HTTP::Message::PSGI'; # (part of Plack)
    requires 'HTTP::Request::Common';
};

