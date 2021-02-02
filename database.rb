describe 'database' do
  def run_script(commands)
    raw_output=nil
    IO.popen("./db.c","r+") do |pipe|
      commands.each do |command|
        pipe.close_write
      end
        raw_output=pipe.gets(nil)
    end
      raw_output.split("\n")
  end

    it 'inserts and retrieves a row' do
      result = run_script([
        "insert 1 user1 person1@ex.com",
        "select",
        ".exit"
      ])
      expect(result).to match_array([
        "db > Executed.",
        "db > (1, user1, person1@ex.com)",
        "Executed.",
        "db > ",
      ])
  end
end
