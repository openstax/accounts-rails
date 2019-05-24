module OpenStax
  module Accounts
    module HasManyThroughGroups
      module ActiveRecord
        module Base
          def self.included(base)
            base.extend(ClassMethods)
          end

          module ClassMethods
            def has_many_through_groups(groups_name, name, options = {})
              options = {class_name: name.to_s.classify}.merge(options)
              association_name = "direct_#{name.to_s}".to_sym

              OpenStax::Accounts::Group.class_exec do
                has_many association_name, options

                define_method(name) do
                  OpenStax::Accounts::Group.includes(association_name)
                    .where(openstax_uid: supertree_group_ids)
                    .map { |g| g.send(association_name).to_a }.flatten.uniq
                end
              end

              class_exec do
                has_many association_name, options if options[:as]

                define_method(name) do
                  direct_records = respond_to?(association_name) ? \
                                     send(association_name).to_a : []
                  indirect_records = OpenStax::Accounts::Group
                    .includes(association_name).where(
                      openstax_uid: send(groups_name).map do |g|
                        g.supertree_group_ids
                      end.flatten.uniq
                    )
                    .map { |g| g.send(association_name).to_a }
                  (direct_records + indirect_records).flatten.uniq
                end
              end
            end
          end
        end
      end
    end
  end
end

::ActiveRecord::Base.send(
  :include, OpenStax::Accounts::HasManyThroughGroups::ActiveRecord::Base
)
