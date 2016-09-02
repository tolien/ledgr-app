class DaytumImportJob < ActiveJob::Base
  queue_as :default

  def perform(user_id, file)
    importer = Importer.new
    user = User.find(user_id)
    unless user.nil?
      importer.import file, user
    end
  end
end
