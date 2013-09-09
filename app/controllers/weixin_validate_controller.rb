#encoding:utf-8
require 'digest/sha1'
require 'rexml/document'
require 'mechanize'
include REXML
class WeixinValidateController < ApplicationController
skip_before_filter :verify_authenticity_token
#protect_from_forgery :except => :create
include REXML
  def supermall
     mytoken = 'tan1feng0supermall'
     for_valid_param =[]
     for_valid_param << mytoken
     for_valid_param << params[:timestamp]
     for_valid_param << params[:nonce]
     string_for_return = '无效请求'
     if params[:signature] and(params[:signature] == Digest::SHA1.hexdigest(for_valid_param.sort!.join()))
     puts "*"*10,"认证成功","*"*10
     string_for_return = params[:echostr]
       #send_data(string_for_return)
      render(:text => string_for_return)
    else
     render()
     end
  end
  def supermall_post
     content = params[:Content]
     sign = params[:signature]
     puts 'do post:',content, sign,params,request.method,request.headers
     #puts 'body:',request.body().string

     doc = Document.new(request.body().string)
     doc.elements.each("xml/ToUserName") {|ele| puts ele, ele.text}
     root = doc.root
     puts root.to_a()
     @to_user_name = root.elements["ToUserName"].text.strip()
     @from_user_name = root.elements["FromUserName"].text.strip()
     @create_time = root.elements["CreateTime"].text.strip()
     @msg_type = root.elements["MsgType"].text.strip()
     @msg_id = root.elements["MsgId"].text.strip()

     puts "ToUserName:#{@to_user_name}, FromUserName:#{@from_user_name}, CreateTime:#{@create_time}, MsgType:#{@msg_type}, MsgId:#{@msg_id}"

     #content = root.elements["Content"].text.strip()
     puts 'xml content:',root.to_a()
     
     if ( @msg_type == "text" )
       result = mixed_message(doc)
     elsif ( @msg_type == "location" )
       result = location_msg(doc)
     end

     render(:text => result)
  end

  private

  def location_msg(doc)
    root = doc.root
    location_x = root.elements["Location_X"].text.strip()
    location_y = root.elements["Location_Y"].text.strip()
    scale = root.elements["Scale"].text.strip()
    label = root.elements["Label"].text.strip()
    puts "location message, x:#{location_x}, y:#{location_y}, scale:#{scale}, label:#{label}"

    agent = Mechanize.new
    page = agent.get('http://api.map.baidu.com/place/v2/search?&query=商场&location=39.984114,116.382983&radius=2000&output=json&ak=1a88109bb973a17b0285501aae43642b')
    puts page

  end

  def mixed_message(doc)
    # create return xml
    agent = Mechanize.new
    page = agent.get('http://api.map.baidu.com/place/v2/search?&query=商场&location=39.984114,116.382983&radius=2000&output=json&ak=1a88109bb973a17b0285501aae43642b')
    puts "page:#{page}"

    result = ''
    ret_root = Element.new( "xml" )
    ret_to_user_name = Element.new("ToUserName")
    ret_to_user_name.add_text CData.new(@from_user_name)
    ret_root.add_element(ret_to_user_name)

    ret_from_user_name = Element.new("FromUserName")
    ret_from_user_name.add_text(CData.new(@to_user_name))
    ret_root.add_element(ret_from_user_name)

    ret_create_time = Element.new("CreateTime")
    ret_create_time.add_text(Time.now.to_i.to_s)
    ret_root.add_element(ret_create_time)

    ret_msg_type = Element.new("MsgType")
    ret_msg_type.add_text(CData.new("news"))
    ret_root.add_element(ret_msg_type)

    ret_article_count = Element.new("ArticleCount")
    ret_article_count.add_text(1.to_s())
    ret_root.add_element(ret_article_count)

    ret_articles = Element.new("Articles")

    ret_item = Element.new("item")

    ret_item_title = Element.new("Title")
    ret_item_title.add_text(CData.new("朝阳大悦城-bj"))
    ret_item.add_element(ret_item_title)
    ret_item_desc = Element.new("Description").add_text(CData.new("朝阳大悦城位于北京城市东部朝青板块核心地段，朝阳北路与青年路交叉口的东北角，四、五环之间，与姚家园路、朝阳路共同构成三横三纵路网体系，集中了地铁、公交等多种出行工具，交通极为便利。得意于城市发展的重心东移，区域内已经云集了众多高档住宅，逐渐成为“中央生活区”，北京新贵人群、高级城市白领置业的首选之地。"))
    ret_item.add_element(ret_item_desc)
    ret_item.add_element(Element.new("PicUrl").add_text(CData.new("http://i2.sinaimg.cn/hs/2010/1110/S21634T1289357368263.jpg")))
    ret_item.add_element(Element.new("Url").add_text(CData.new("http://www.cyjoycity.com/index.html")))

    ret_articles.add_element(ret_item)


    ret_root.add_element(ret_articles)


    #ret_content = Element.new("Content")
    #ret_content.add_text(CData.new("message received."));
    #ret_root.add_element(ret_content)
    #ret_root.write($stdout)
    ret_root.write(result)
    puts "result:#{result}"

    return result

  end
end
