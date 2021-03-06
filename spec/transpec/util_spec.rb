# coding: utf-8

require 'spec_helper'
require 'transpec/util'
require 'ast'

module Transpec
  describe Util do
    include_context 'parsed objects'
    include ::AST::Sexp

    describe '#const_name' do
      subject { Util.const_name(ast) }

      context 'when the passed node is not :const type' do
        let(:ast) do
          s(:lvasgn, :foo,
            s(:int, 1))
        end

        it 'returns nil' do
          should be_nil
        end
      end

      [
        ['Foo',           'Foo'],
        ['Foo::Bar',      'Foo::Bar'],
        ['Foo::Bar::Baz', 'Foo::Bar::Baz'],
        ['::Foo',         'Foo'],
        ['::Foo::Bar',    'Foo::Bar'],
        ['variable::Foo', 'variable::Foo']
      ].each do |source, expected_return_value|
        context "when the source is #{source.inspect}" do
          let(:source) { source }

          it "returns #{expected_return_value.inspect}" do
            should == expected_return_value
          end
        end
      end
    end

    describe '#here_document?' do
      subject { Util.here_document?(ast) }

      context 'when pseudo-variable __FILE__ node is passed' do
        let(:source) { '__FILE__' }

        it { should be_false }
      end
    end

    describe '#expand_range_to_adjacent_whitespaces' do
      let(:node) { ast.each_node.find { |n| n.type == :block } }
      let(:range) { node.loc.begin }
      subject(:expanded_range) { Util.expand_range_to_adjacent_whitespaces(range) }

      context 'when the range is adjacent to whitespaces' do
        let(:source) do
          <<-END
            1.times  { \t do_something }
          END
        end

        it 'returns expanded range that contains adjacent whitespaces' do
          expanded_range.source.should == "  { \t "
        end
      end

      context 'when the range is not adjacent to whitespaces' do
        let(:source) do
          <<-'END'
            1.times{do_something }
          END
        end

        it 'returns un-expanded range' do
          expanded_range.source.should == '{'
        end
      end
    end
  end
end
