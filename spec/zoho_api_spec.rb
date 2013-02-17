$:.unshift File.join('..', File.dirname(__FILE__), 'lib')

require 'spec_helper'
require 'zoho_api'
require 'xmlsimple'

describe ZohoApi do

  def add_dummy_contact
    c = {:first_name => 'BobDifficultToMatch', :last_name => 'SmithDifficultToMatch',
         :email => 'bob@smith.com'}
    @zoho.add_record('Contacts', c)
  end

  def delete_dummy_contact
    c = @zoho.find_records(
        'Contacts', :email, '=', 'bob@smith.com')
    @zoho.delete_record('Contacts', c[0][:contactid]) unless c == []
  end


  before(:all) do
    base_path = File.join(File.dirname(__FILE__), 'fixtures')
    config_file = File.join(base_path, 'zoho_api_configuration.yaml')
    #params = YAML.load(File.open(config_file))
    #@zoho = ZohoApi::Crm.new(params['auth_token'])
    @sample_pdf = File.join(base_path, 'sample.pdf')
    modules = ['Accounts', 'Contacts', 'Leads', 'Potentials']
    #api_key = '783539943dc16d7005b0f3b78367d5d2'
    #api_key = 'e194b2951fb238e26bc096de9d0cf5f8'
    api_key = '62cedfe9427caef8afb9ea3b5bf68154'
    @zoho = ZohoApi::Crm.new(api_key, modules)
    @h_smith = { :first_name => 'Robert',
          :last_name => 'Smith',
          :email => 'rsmith@smithereens.com',
          :department => 'Waste Collection and Management',
          :phone => '13452129087',
          :mobile => '12341238790'
    }
    #contacts = @zoho.find_records('Contacts', :email, '=', @h_smith[:email])
    #contacts.each { |c| @zoho.delete_record('Contacts', c[:contactid]) } unless contacts.nil?
  end

  it 'should add a new contact' do
    @zoho.add_record('Contacts', @h_smith)
    contacts = @zoho.find_records('Contacts', :email, '=', @h_smith[:email])
    @zoho.delete_record('Contacts', contacts[0][:contactid])
    contacts.should_not eq(nil)
    contacts.count.should eq(1)
  end

  it 'should attach a file to a contact record' do
    pending
    @zoho.add_record('Contacts', @h_smith)
    contacts = @zoho.find_records('Contacts', :email, '=', @h_smith[:email])
    @zoho.add_file('Contacts', contacts[0][:contactid], @sample_pdf)
    #@zoho.delete_record('Contacts', contacts[0][:contactid])
  end

  it 'should delete a contact record with id' do
    add_dummy_contact
    c = @zoho.find_records('Contacts', :email, '=', 'bob@smith.com')
    @zoho.delete_record('Contacts', c[0][:contactid])
  end

  it 'should find by module and field for columns' do
    add_dummy_contact
    r = @zoho.find_records('Contacts', :email, '=', 'bob@smith.com')
    r[0][:email].should eq('bob@smith.com')
    delete_dummy_contact
  end

  it 'should find by module and id' do
    add_dummy_contact
    r = @zoho.find_records('Contacts', :email, '=', 'bob@smith.com')
    r[0][:email].should eq('bob@smith.com')
    id = r[0][:contactid]
    c = @zoho.find_record_by_id('Contacts', id)
    c[0][:contactid].should eq(id)
    delete_dummy_contact
  end

  it 'should get a list of fields for a module' do
    r = @zoho.fields('Contacts')
    r.count.should be >= 35
    r = @zoho.fields('Leads')
    r.count.should be >= 23
    r = @zoho.fields('Potentials')
    r.count.should be >= 15
    r = @zoho.fields('Accounts')
    r.count.should >= 30
  end

  it 'should retrieve records by module name' do
    r = @zoho.some('Contacts')
    r.should_not eq(nil)
    r[0][:email].should_not eq(nil)
    r.count.should be > 1
  end

  it 'should return related records by module and id' do
    pending
    r = @zoho.some('Accounts').first
    pp r
    related = @zoho.related_records('Accounts', r[:accountid], 'Attachments')
  end

  it 'should return events' do
    r = @zoho.some('Events').first
    r.should_not eq(nil)
  end

  it 'should return users' do
    r = @zoho.users('AllUsers')
    r.should_not eq(nil)
  end

  it 'should do a full CRUD lifecycle on tasks' do
    mod_name = 'Tasks'
    fields = @zoho.fields(mod_name)
    fields.count >= 10
    fields.index(:task_owner).should_not eq(nil)
    @zoho.add_record(mod_name, {:task_owner => 'Task Owner', :subject => 'Test Task', :due_date => '1/1/2100'})
    r = @zoho.some(mod_name).first
    pp r
    r.should_not eq(nil)
  end

  it 'should update a contact' do
    @zoho.add_record('Contacts', @h_smith)
    contact = @zoho.find_records('Contacts', :email, '=', @h_smith[:email])
    h_changed = { :email => 'robert.smith@smithereens.com' }
    @zoho.update_record('Contacts', contact[0][:contactid], h_changed)
    changed_contact = @zoho.find_records('Contacts', :email, '=', h_changed[:email])
    changed_contact[0][:email].should eq(h_changed[:email])
    @zoho.delete_record('Contacts', contact[0][:contactid])
  end

end
