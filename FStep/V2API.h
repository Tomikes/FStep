//
//  V2API.h
//  V2EX
//
//  Created by mike on 8/1/16.
//  Copyright © 2016 mike. All rights reserved.
//
//

/**
 0:
 show all node节点 https://www.v2ex.com/api/nodes/all.json

 1.单个node的info，比如python＝＝》 info:https://www.v2ex.com/api/nodes/show.json?name=python
 2.在找该node下面的topics ＝＝？ https://www.v2ex.com/api/topics/show.json?node_name=python&p=1 ＝＝>返回的一系列topic，保存id就是topic_id
 3.查看某个话题下面的回复replies
 比如查看topicid为296246这个话题的回复
 https://www.v2ex.com/api/replies/show.json?topic_id=296246
 
 "member" : {
 "id" : 87718,
 "username" : "zhongshaohua",
 "tagline" : "None",
 "avatar_mini" : "//cdn.v2ex.co/avatar/a6cb/a635/87718_mini.png?m=1458045689",
 "avatar_normal" : "//cdn.v2ex.co/avatar/a6cb/a635/87718_normal.png?m=1458045689",
 "avatar_large" : "//cdn.v2ex.co/avatar/a6cb/a635/87718_large.png?m=1458045689"
 },
                                                    //member中的username
 4.查看某个用户的topics    http://www.v2ex.com/member/zhongshaohua/topics
                                          username
 5.查看用户回复帖子：https://www.v2ex.com/member/zhongshaohua/replies?p=2
 
 6。http://www.v2ex.com/my/following 查看收藏的node，topics，特别关注
 case V2HotNodesTypeNodes:
 urlString = @"/my/nodes";
 break;
 case V2HotNodesTypeMembers:
 urlString = @"my/following";
 break;
 case V2HotNodesTypeFav:
 urlString = @"my/topics";
 */




/**
 * https://www.v2ex.com/api/topics/hot.json
 * Method: GET
 * Authentication: None
 *相当于首页右侧的 10 大每天的内容。
 */
/**

 最新主题
 
 
 相当于首页的“全部”这个 tab 下的最新内容。
 
 https://www.v2ex.com/api/topics/latest.json
 
 Method: GET
 Authentication: None
 
 */


 /**
  显示某个topic信息
  https://www.v2ex.com/api/topics/show.json?node_name=music&p=1

python
if (nodeId) {
    parameters = @{
                   @"node_id": nodeId,
                   @"p": @(page)
                   };
}
if (name) {
    parameters = @{
                   @"node_name": name,
                   @"p": @(page)
                   };
}
if (username) {
    parameters = @{
                   @"username": username,
                   @"p": @(page)
                   };
}

*/

/**
     11大主要的topic
 https://www.v2ex.com/?tab=nodes
 。。。
 
 
 */


/**
 
 用户主页
 
 获得指定用户的自我介绍，及其登记的社交网站信息。
 
 https://www.v2ex.com/api/members/show.json
 
 Method: GET
 Authentication: None
 接受以下参数之一：
 
 username: 用户名
 id: 用户在 V2EX 的数字 ID
 例如：
 
 https://www.v2ex.com/api/members/show.json?username=Livid
 https://www.v2ex.com/api/members/show.json?id=1

 
 */


/**
 
 节点信息
 
 获得指定节点的名字，简介，URL 及头像图片的地址。
 
 https://www.v2ex.com/api/nodes/show.json
 
 Method: GET
 Authentication: None
 接受参数：
 
 name: 节点名（V2EX 的节点名全是半角英文或者数字）
 例如：
 
 https://www.v2ex.com/api/nodes/show.json?name=music
 
 */


#import <Foundation/Foundation.h>

@interface V2API : NSObject

@end
