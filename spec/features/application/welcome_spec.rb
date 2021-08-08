require 'rails_helper'


RSpec.describe 'application', :vcr do
  it 'displays welcome message' do
    visit '/'

    expect(page).to have_content('Welcome!')
  end
end
