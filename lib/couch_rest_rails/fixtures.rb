module CouchRestRails
  module Fixtures

    extend self

    def blurbs
      res = []
      res << "Cras dictum. Maecenas ut turpis. In vitae erat ac orci dignissim eleifend. Nunc quis justo. Sed vel ipsum in purus tincidunt pharetra. Sed pulvinar, felis id consectetuer malesuada, enim nisl mattis elit, a facilisis tortor nibh quis leo. Sed augue lacus, pretium vitae, molestie eget, rhoncus quis, elit. Donec in augue. Fusce orci wisi, ornare id, mollis vel, lacinia vel, massa. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas."
      res << "Aliquam lectus orci, adipiscing et, sodales ac, feugiat non, lacus. Ut dictum velit nec est. Quisque posuere, purus sit amet malesuada blandit, sapien sapien auctor arcu, sed pulvinar felis mi sollicitudin tortor. Maecenas volutpat, nisl et dignissim pharetra, urna lectus ultrices est, vel pretium pede turpis id velit. Aliquam sagittis magna in felis egestas rutrum. Proin wisi libero, vestibulum eget, pulvinar nec, suscipit ut, mi. Integer in arcu ultricies leo dapibus ultricies. Sed rhoncus lobortis dolor. Suspendisse dolor. Mauris sapien velit, pulvinar non, rutrum non, consectetuer eget, metus. Morbi tincidunt lorem at urna. Etiam porta. Ut mauris. Phasellus tristique rhoncus magna. Nam tincidunt consequat urna. Sed tempor."
      res << "Nunc auctor bibendum eros. Maecenas porta accumsan mauris. Etiam enim enim, elementum sed, bibendum quis, rhoncus non, metus. Fusce neque dolor, adipiscing sed, consectetuer et, lacinia sit amet, quam. Suspendisse wisi quam, consectetuer in, blandit sed, suscipit eu, eros. Etiam ligula enim, tempor ut, blandit nec, mollis eu, lectus. Nam cursus. Vivamus iaculis. Aenean risus purus, pharetra in, blandit quis, gravida a, turpis. Donec nisl. Aenean eget mi. Fusce mattis est id diam. Phasellus faucibus interdum sapien. Duis quis nunc. Sed enim."
      res << "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Morbi commodo, ipsum sed pharetra gravida, orci magna rhoncus neque, id pulvinar odio lorem non turpis. Nullam sit amet enim. Suspendisse id velit vitae ligula volutpat condimentum. Aliquam erat volutpat. Sed quis velit. Nulla facilisi. Nulla libero. Vivamus pharetra posuere sapien. Nam consectetuer. Sed aliquam, nunc eget euismod ullamcorper, lectus nunc ullamcorper orci, fermentum bibendum enim nibh eget ipsum. Donec porttitor ligula eu dolor. Maecenas vitae nulla consequat libero cursus venenatis. Nam magna enim, accumsan eu, blandit sed, blandit a, eros."
      res << "Morbi non erat non ipsum pharetra tempus. Donec orci. Proin in ante. Pellentesque sit amet purus. Cras egestas diam sed ante. Etiam imperdiet urna sit amet risus. Donec ornare arcu id erat. Aliquam ultrices scelerisque sem. In elit nulla, molestie vel, ornare sit amet, interdum vel, mauris. Etiam dignissim imperdiet metus."
      res << "Donec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor."
    end

    def load(database)
      fixture_files = []
      return  "Database '#{database}' doesn't exists" unless (database == "*" ||
                                                              File.exist?(File.join(RAILS_ROOT, CouchRestRails.setup_path, database)))
      Dir[File.join(RAILS_ROOT, CouchRestRails.setup_path, database)].each do |db|
        db_name =COUCHDB_CONFIG[:db_prefix] +  File.basename( db) +
          COUCHDB_CONFIG[:db_suffix]
        res = CouchRest.get("#{COUCHDB_CONFIG[:host_path]}/#{db_name}") rescue nil
        if res
          db_con = CouchRest.database("#{COUCHDB_CONFIG[:host_path]}/#{db_name}")
          Dir.glob(File.join(RAILS_ROOT, CouchRestRails.fixture_path, "#{database}.yml")).each do |file|
            db_con.bulk_save(YAML::load(ERB.new(IO.read(file)).result).map {|f| f[1]})
            fixture_files << File.basename(file)
          end
        end
        if fixture_files.empty?
          return "No fixtures found in #{CouchRestRails.fixture_path}"
        else
          return "Loaded the following fixture files into '#{db}': #{fixture_files.join(', ')}"
        end
      end
    end

    def dump(database)
      return  "Database '#{database}' doesn't exists" unless (database == "*" ||
                                                              File.exist?(File.join(RAILS_ROOT, CouchRestRails.setup_path, database)))
      Dir[File.join(RAILS_ROOT, CouchRestRails.setup_path, database)].each do |db|
        db_name =COUCHDB_CONFIG[:db_prefix] +  File.basename( db) +
          COUCHDB_CONFIG[:db_suffix]
        res = CouchRest.get("#{COUCHDB_CONFIG[:host_path]}/#{db_name}") rescue nil
        if res
          File.open(File.join(RAILS_ROOT, CouchRestRails.fixture_path, "#{database}.yml"), 'w' ) do |file|
            yaml_hash = {}
            db_con = CouchRest.database("#{COUCHDB_CONFIG[:host_path]}/#{db_name}")
            docs = db_con.documents(:include_docs =>true )
            docs["rows"].each { |data|
              doc = data["doc"]
              unless  (doc['_id'] =~ /^_design*/) == 0
                doc.delete('_rev')
                yaml_hash[doc['_id']] = doc
              end
            }
            file.write yaml_hash.to_yaml
          end
        end
      end
    end

    def random_blurb
      blurbs.sort_by {rand}.first
    end

  end
end
