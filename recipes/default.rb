require_recipe 'ruby-shadow'

node[:users].each do |name, conf|
  if !conf 
    # :username => false
    user name do
      action :remove
    end
  else

    home_dir = conf[:home] || "/home/#{name}"

    # Create the group
    group conf[:group] unless conf[:group].nil?

    # Create the user
    user name do
      gid conf[:group] unless conf[:group].nil?
      password conf[:password]
      shell conf[:shell]
      home home_dir
      action :create
    end

    # Add the user to additional groups
    conf[:groups].each do |g|
      group g do
        action :modify
        members name
        append true
      end
    end unless conf[:groups].nil?

    # Create the home dir
    directory home_dir do
      owner name
      mode 0755
    end

    # Create the .ssh dir
    directory "#{home_dir}/.ssh" do
      owner name
      mode 0755
    end

    # Create the dot files
    conf[:dotfiles].each do |fn, fc|
      file home_dir + "/" + fn do
        owner name
        content fc
      end
    end unless conf[:dotfiles].nil?
    
  end

end
