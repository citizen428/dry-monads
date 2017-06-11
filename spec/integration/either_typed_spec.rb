require 'dry-types'

RSpec.describe(Dry::Monads::Either) do
  either = Dry::Monads::Either
  left = either::Left.method(:new)

  before do
    module Test
      class Operation
        wrap_error = -> error { Dry::Types::Definition.new(error).constrained(type: error) }

        Errors =
          wrap_error.(ZeroDivisionError) |
          wrap_error.(NoMethodError)

        include Dry::Monads::Either(Errors)
      end
    end
  end

  subject { Test::Operation.new }

  let(:division_error) { 1 / 0 rescue $! }
  let(:no_method_error) { self.missing rescue $! }
  let(:runtime_error) { 'foo'.freeze.upcase! rescue $! }

  it 'passes with known errors' do
    expect(subject.Left(division_error)).to eql(left.(division_error))
    expect(subject.Left(no_method_error)).to eql(left.(no_method_error))
  end

  it 'raises an error on unexpected type' do
    expect { subject.Left(runtime_error) }.to raise_error(Dry::Types::ConstraintError)
  end
end
