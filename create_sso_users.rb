#! /usr/bin/env ruby

def create_oomph(name, role)
  email = name + "+#{role.to_s.split('_')[1]}" + '@oomphhq.com'
  create_user(email, role, 'Oomph', {first_name: name, last_name: name})
end

def create_user(email, role, org_name=nil, atts={})
  org_name = email if org.nil? # like sachin, default to email
  org = Organization.find_by(name: org_name)

  defaults = {
    email: email,
    password: 'default',
    phone_number: '0',
    first_name: '.',
    last_name: '.',
    has_accepted_tos: true,
    wants_newsletter: false
  }

  atts = defaults.merge! atts # override default values
  
  user = User.find_or_initialize_by(email: email)
  user.roles << role
  user.organizations << org
  user.update_attributes(atts)
  user.save!
end

def create_three(name)
  [:oomph, :adomatic_publisher, :adomatic_delegate].each do |role|
    create_oomph(name, role)
  end
 end

# keep the methods, change this part (duh)
%w(leighann james tony isabel).each {|x| create_three x}
