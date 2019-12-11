# frozen_string_literal: true

module ActiveRecord
  module Postgres
    module Constraints
      module Types
        module Unique
          class << self
            def to_sql(table, name_or_conditions, conditions = nil)
              name, conditions = ActiveRecord::Postgres::Constraints.
                normalize_name_and_conditions(table, name_or_conditions, conditions)
              "CONSTRAINT #{name} UNIQUE (#{normalize_schema_conditions(conditions)})"
            end

            def to_schema_dump(constraint)
              name = constraint['conname']
              conditions = constraint['definition'].gsub(/^UNIQUE\s*\((.*)\)\s*$/, '\\1')
              "    t.unique_constraint :#{name}, [#{normalize_sql_conditions(conditions)}]"
            end

            def example_constraint
              "'my_column'"
            end

            private

            # Create SQL arguments from schema
            def normalize_schema_conditions(conditions)
              case conditions
              when Array then conditions.map(&:to_s).join(', ')
              when Symbol then conditions.to_s
              when String then conditions
              else raise ArgumentError.new("Invalid conditions for unique constraint #{conditions.inspect}")
              end
            end
            
            # Create schema arguments from SQL
            def normalize_sql_conditions(conditions)
              conditions.split(',').collect do |cond|
                cond.strip!
                if ['"'.freeze, '\''.freeze].include? cond[0]
                  cond
                else
                  ':'+cond
                end
              end.join(', ')
            end
          end
        end
      end
    end
  end
end
