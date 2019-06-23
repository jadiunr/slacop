requires 'YAML::Tiny';
requires 'Slack::RTM::Bot';
requires 'Furl';
requires 'Text::Shirasu';

on 'develop' => sub {
  requires 'Pry';
};