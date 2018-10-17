class DaytumImportJob < ActiveJob::Base
  queue_as :default

  def perform(user_id, file, delete_on_completion=false)
    importer = Importer.new
    user = User.find(user_id)
    unless user.nil?
      importer.import file, user
    end

    if delete_on_completion
      File.delete(file)
    end
  end
end
