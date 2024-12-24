namespace :edm do
  desc 'Load Mocks'
  task :load_mocks, [:plan_dir] => :environment do |_cmd, args|
    args.to_h => { plan_dir: }

    plan_dir =
      case
      when plan_dir.blank?
        puts "Usage: rake edm:load_mocks[plan_dir]"
        exit 1
      else
        Pathname(plan_dir)
      end

    raise "could not find plan_dir: #{plan_dir}" unless plan_dir.exist?

    yml = plan_dir / 'plan.yml'
    yaml = plan_dir / 'plan.yaml'
    plan_path =
      case
      when yaml.exist?
        yaml
      when yml.exist?
        yml
      else
        raise "could not find plan.yml or plan.yaml in #{plan_dir}"
      end

    Edm::LoadMocks.new(plan_path:).perform
  end
end
