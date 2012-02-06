use strict;
use warnings;
use Test::More;
use HTML::TreeBuilder;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_widget_tags {
        { by_flag => { repeatable => { wrapper => 1 }, contains => { wrapper => 1 } } }
    }
    has '+name' => ( default => 'test_form' );
    has_field 'foo' => ( type => 'Repeatable', num_when_empty => 2,
        wrapper_attr => { class => 'hfhrep' }, label => 'Foo Records' );
    has_field 'foo.one';
    has_field 'foo.two';
    has_field 'foo.three';
    has_field 'bar';

    sub field_html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        if( $type eq 'wrapper' && $field->has_flag('is_contains') ) {
            $attr->{class} = ['hfh', 'repinst'];
        }
        return $attr;
    }
}

my $form = Test::Form->new;
$form->process({});
ok( $form, 'form built' );
my $rendered = $form->render;
my $expected =
'<form id="test_form" method="post">
  <fieldset class="hfhrep"><legend>Foo Records</legend>
    <div class="hfh repinst">
      <div>
        <label for="foo.0.one">One</label>
        <input type="text" name="foo.0.one" id="foo.0.one" value="" />
      </div>
      <div>
        <label for="foo.0.two">Two</label>
        <input type="text" name="foo.0.two" id="foo.0.two" value="" />
      </div>
      <div>
        <label for="foo.0.three">Three</label>
        <input type="text" name="foo.0.three" id="foo.0.three" value="" />
      </div>
    </div>
    <div class="hfh repinst">
      <div><label for="foo.1.one">One</label>
        <input type="text" name="foo.1.one" id="foo.1.one" value="" />
      </div>
      <div>
        <label for="foo.1.two">Two</label>
        <input type="text" name="foo.1.two" id="foo.1.two" value="" />
      </div>
      <div>
        <label for="foo.1.three">Three</label>
        <input type="text" name="foo.1.three" id="foo.1.three" value="" />
      </div>
    </div>
  </fieldset>
  <div>
    <label for="bar">Bar</label>
    <input type="text" name="bar" id="bar" value="" />
  </div>
</form>';

my $exp = HTML::TreeBuilder->new_from_content($expected);
my $got = HTML::TreeBuilder->new_from_content($rendered);
is( $got->as_HTML, $exp->as_HTML, "rendered as expected" );

done_testing;
