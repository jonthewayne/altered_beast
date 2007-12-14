require File.dirname(__FILE__) + '/../spec_helper'

describe Forum do
  it "formats body html" do
    f = Forum.new :description => 'bar'
    f.description_html.should be_nil
    f.send :format_content
    f.description_html.should == 'bar'
  end

  #def test_should_list_only_top_level_topics
  #  assert_models_equal [topics(:sticky), topics(:il8n), topics(:ponies), topics(:pdi)], forums(:rails).topics
  #end
  #
  #def test_should_list_recent_posts
  #  assert_models_equal [posts(:il8n), posts(:ponies), posts(:pdi_rebuttal), posts(:pdi_reply), posts(:pdi),posts(:sticky) ], forums(:rails).posts
  #end
  #
  #def test_should_find_recent_post
  #  assert_equal posts(:il8n), forums(:rails).recent_post
  #end
  #
  #def test_should_find_recent_topic
  #  assert_equal topics(:il8n), forums(:rails).recent_topic
  #end
  #
  #def test_should_find_first_recent_post
  #  assert_equal topics(:il8n), forums(:rails).recent_topic
  #end
  #
  #def test_should_find_ordered_forums
  #  assert_equal [forums(:comics), forums(:rails)], Forum.find_ordered
  #end
end