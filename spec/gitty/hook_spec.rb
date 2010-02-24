require File.expand_path('../../spec_helper', __FILE__)

describe Gitty::Hook do
  before(:each) do
    Gitty::Hook.stub!(:available_hooks_search_paths).and_return([SandboxWorld::GITTY_ASSETS + "hooks"])
    create_file(SandboxWorld::GITTY_ASSETS + "hooks/submodule_updater", <<-EOF)
#!/bin/bash
# description: managers submodule updating for you
# targets: ["post-checkout", "post-merge"]
...
EOF
    create_file(SandboxWorld::GITTY_ASSETS + "hooks/no_messy_whitespace", <<-EOF)
#!/bin/bash
# description: prevents you from committing messy whitespace
# targets: ["pre-commit"]
...
EOF
  end

  describe ".find_all" do
    it "returns all available hooks" do
      Gitty::Hook.find_all(:available).map(&:name).should == %w[no_messy_whitespace submodule_updater]
    end
  end

  describe "#.find" do
    it "returns an available hook by name" do
      Gitty::Hook.find("submodule_updater", :kind => :available).name.should == "submodule_updater"
      Gitty::Hook.find("no_messy_whitespace", :kind => :available).name.should == "no_messy_whitespace"
    end
  end

  describe "#installed" do
    it "returns nil if the hook is not installed" do
      Gitty::Hook.find("submodule_updater", :kind => :available).installed.should be_nil
    end
  end

  describe "#meta_data" do
    it "reads the meta_data of a given file" do
      Gitty::Hook.find("submodule_updater", :kind => :available).meta_data
    end
  end

  describe "#install" do
    it "copies an available hook to the install path and links it into the targets" do
      @hook = Gitty::Hook.find("submodule_updater", :kind => :available)
      @hook.install
      File.exist?(".git/hooks/local/hooks/submodule_updater").should be_true
      File.executable?(".git/hooks/local/hooks/submodule_updater").should be_true
      File.exist?(".git/hooks/local/post-checkout.d/submodule_updater").should be_true
      File.exist?(".git/hooks/local/post-merge.d/submodule_updater").should be_true
    end

    it "installs a hook into shared" do
      @hook = Gitty::Hook.find("submodule_updater", :kind => :available)
      @hook.install(:shared)
      File.exist?(".git/hooks/shared/hooks/submodule_updater").should be_true
      File.executable?(".git/hooks/shared/hooks/submodule_updater").should be_true
      File.exist?(".git/hooks/shared/post-checkout.d/submodule_updater").should be_true
      File.exist?(".git/hooks/shared/post-merge.d/submodule_updater").should be_true
    end
  end
end
