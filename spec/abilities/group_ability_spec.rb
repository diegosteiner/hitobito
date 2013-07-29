require 'spec_helper'


describe GroupAbility do


  subject { ability }
  let(:ability) { Ability.new(role.person.reload) }


  context "layer full" do
    let(:role) { Fabricate(Group::TopGroup::Leader.name.to_sym, group: groups(:top_group)) }

    context "without specific group" do
      it "may not create subgroup" do
        should_not be_able_to(:create, Group.new)
      end
    end

    context "in own group" do
      let(:group) { role.group }

      it "may create subgroup" do
        should be_able_to(:create, group.children.new)
      end

      it "may edit group" do
        should be_able_to(:update, group)
      end

      it "may not modify superior" do
        should_not be_able_to(:modify_superior, group)
      end
    end

    context "in group from lower layer" do
      let(:group) { groups(:bottom_layer_one) }

      it "may create subgroup" do
        should be_able_to(:create, group.children.new)
      end

      it "may edit group" do
        should be_able_to(:update, group)
      end

      it "may modify superior" do
        should be_able_to(:modify_superior, group)
      end

      it "may modify superior in new group" do
        g = Group::BottomLayer.new
        g.parent = group.parent
        should be_able_to(:modify_superior, g)
      end
    end
  end

  context "layer full in lower layer" do
    let(:role) { Fabricate(Group::BottomLayer::Leader.name.to_sym, group: groups(:bottom_layer_one)) }

    context "in own group" do
      let(:group) { role.group }

      it "may edit group" do
        should be_able_to(:update, group)
      end

      it "may not modify superior" do
        should_not be_able_to(:modify_superior, group)
      end
    end
  end

  context "group full" do
    let(:role) { Fabricate(Group::GlobalGroup::Leader.name.to_sym, group: groups(:toppers)) }

    context "in own group" do
      let(:group) { role.group }
      it "may not create subgroup" do
        should_not be_able_to(:create, group.children.new)
      end

      it "may edit group" do
        should be_able_to(:update, group)
      end

      it "may not modify superior" do
        should_not be_able_to(:modify_superior, group)
      end
    end

    context "without specific group" do
      it "may not create subgroup" do
        should_not be_able_to(:create, Group.new)
      end
    end

    context "in other group from same layer" do
      let(:group) { groups(:top_group) }
      it "may not create subgroup" do
        should_not be_able_to(:create, group.children.new)
      end
    end

    context "in group from lower layer" do
      let(:group) { groups(:bottom_layer_one) }
      it "may not create subgroup" do
        should_not be_able_to(:create, group.children.new)
      end
    end
  end

  context "deleted group" do
    let(:group) { groups(:bottom_layer_two) }
    let(:role) { Fabricate(Group::BottomLayer::Leader.name.to_sym, group: group) }
    before do
      group.children.each { |g| g.destroy }
      group.destroy
    end

    it "may not create subgroup" do
      should_not be_able_to(:create, group.children.new)
    end

    it "may not update group" do
      should_not be_able_to(:update, group)
    end

    it "may reactivate group" do
      should be_able_to(:reactivate, group)
    end
  end

end
