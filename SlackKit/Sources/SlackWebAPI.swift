//
// SlackWebAPI.swift
//
// Copyright © 2016 Peter Zignego. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Jay

internal enum SlackAPIEndpoint: String {
    case APITest = "api.test"
    case AuthTest = "auth.test"
    case ChannelsHistory = "channels.history"
    case ChannelsInfo = "channels.info"
    case ChannelsList = "channels.list"
    case ChannelsMark = "channels.mark"
    case ChannelsSetPurpose = "channels.setPurpose"
    case ChannelsSetTopic = "channels.setTopic"
    case ChatDelete = "chat.delete"
    case ChatPostMessage = "chat.postMessage"
    case ChatUpdate = "chat.update"
    case DNDInfo = "dnd.info"
    case DNDTeamInfo = "dnd.teamInfo"
    case EmojiList = "emoji.list"
    case FilesCommentsAdd = "files.comments.add"
    case FilesCommentsEdit = "files.comments.edit"
    case FilesCommentsDelete = "files.comments.delete"
    case FilesDelete = "files.delete"
    case FilesUpload = "files.upload"
    case GroupsClose = "groups.close"
    case GroupsHistory = "groups.history"
    case GroupsInfo = "groups.info"
    case GroupsList = "groups.list"
    case GroupsMark = "groups.mark"
    case GroupsOpen = "groups.open"
    case GroupsSetPurpose = "groups.setPurpose"
    case GroupsSetTopic = "groups.setTopic"
    case IMClose = "im.close"
    case IMHistory = "im.history"
    case IMList = "im.list"
    case IMMark = "im.mark"
    case IMOpen = "im.open"
    case MPIMClose = "mpim.close"
    case MPIMHistory = "mpim.history"
    case MPIMList = "mpim.list"
    case MPIMMark = "mpim.mark"
    case MPIMOpen = "mpim.open"
    case PinsAdd = "pins.add"
    case PinsRemove = "pins.remove"
    case ReactionsAdd = "reactions.add"
    case ReactionsGet = "reactions.get"
    case ReactionsList = "reactions.list"
    case ReactionsRemove = "reactions.remove"
    case RTMStart = "rtm.start"
    case StarsAdd = "stars.add"
    case StarsRemove = "stars.remove"
    case TeamInfo = "team.info"
    case UsersGetPresence = "users.getPresence"
    case UsersInfo = "users.info"
    case UsersList = "users.list"
    case UsersSetActive = "users.setActive"
    case UsersSetPresence = "users.setPresence"
}

public class SlackWebAPI {
    
    public typealias FailureClosure = (error: SlackError)->Void
    
    public enum InfoType: String {
        case Purpose = "purpose"
        case Topic = "topic"
    }
    
    public enum ParseMode: String {
        case Full = "full"
        case None = "none"
    }
    
    public enum Presence: String {
        case Auto = "auto"
        case Away = "away"
    }
    
    private enum ChannelType: String {
        case Channel = "channel"
        case Group = "group"
        case IM = "im"
    }
    
    private let client: SlackClient
    
    required public init(slackClient: SlackClient) {
        self.client = slackClient
    }
    
    //MARK: - RTM
    public func rtmStart(simpleLatest: Bool? = nil, noUnreads: Bool? = nil, mpimAware: Bool? = nil, success: ((response: [String: Any])->Void)?, failure: FailureClosure?) {
        print("** In rtmStart")
        let parameters: [String: Any?] = ["simple_latest": simpleLatest, "no_unreads": noUnreads, "mpim_aware": mpimAware]
        client.api.request(endpoint: .RTMStart, token: client.token, parameters: filterNilParameters(parameters: parameters), successClosure: {
                (response) -> Void in
                print("** Request success: \(response)")
                success?(response: response)
            }) {(error) -> Void in
                print("** Request failure: \(error)")
                failure?(error: error)
            }
    }
    
    //MARK: - Auth Test
    public func authenticationTest(success: ((authenticated: Bool)->Void)?, failure: FailureClosure?) {
        client.api.request(endpoint: .AuthTest, token: client.token, parameters: nil, successClosure: {
            (response) -> Void in
                success?(authenticated: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    //MARK: - Channels
    public func channelHistory(id: String, latest: String = "\(Time.slackTimestamp())", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((history: History?)->Void)?, failure: FailureClosure?) {
        history(endpoint: .ChannelsHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads, success: {
            (history) -> Void in
                success?(history: history)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func channelInfo(id: String, success: ((channel: Channel?)->Void)?, failure: FailureClosure?) {
        info(endpoint: .ChannelsInfo, type:ChannelType.Channel, id: id, success: {
            (channel) -> Void in
                success?(channel: channel)
            }) { (error) -> Void in
                failure?(error: error)
        }
    }
    
    public func channelsList(excludeArchived: Bool = false, success: ((channels: [Any]?)->Void)?, failure: FailureClosure?) {
        list(endpoint: .ChannelsList, type:ChannelType.Channel, excludeArchived: excludeArchived, success: {
            (channels) -> Void in
                success?(channels: channels)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func markChannel(channel: String, timestamp: String, success: ((ts: String)->Void)?, failure: FailureClosure?) {
        mark(endpoint: .ChannelsMark, channel: channel, timestamp: timestamp, success: {
            (ts) -> Void in
                success?(ts:timestamp)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func setChannelPurpose(channel: String, purpose: String, success: ((purposeSet: Bool)->Void)?, failure: FailureClosure?) {
        setInfo(endpoint: .ChannelsSetPurpose, type: .Purpose, channel: channel, text: purpose, success: {
            (purposeSet) -> Void in
                success?(purposeSet: purposeSet)
            }) { (error) -> Void in
                failure?(error: error)
        }
    }
    
    public func setChannelTopic(channel: String, topic: String, success: ((topicSet: Bool)->Void)?, failure: FailureClosure?) {
        setInfo(endpoint: .ChannelsSetTopic, type: .Topic, channel: channel, text: topic, success: {
            (topicSet) -> Void in
                success?(topicSet: topicSet)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    //MARK: - Messaging
    public func deleteMessage(channel: String, ts: String, success: ((deleted: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel": channel, "ts": ts]
        client.api.request(endpoint: .ChatDelete, token: client.token, parameters: parameters, successClosure: { (response) -> Void in
                success?(deleted: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func sendMessage(channel: String, text: String, username: String? = nil, asUser: Bool? = nil, parse: ParseMode? = nil, linkNames: Bool? = nil, attachments: [Attachment?]? = nil, unfurlLinks: Bool? = nil, unfurlMedia: Bool? = nil, iconURL: String? = nil, iconEmoji: String? = nil, success: (((ts: String?, channel: String?))->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["channel":channel, "text":text.slackFormatEscaping(), "as_user":asUser, "parse":parse?.rawValue, "link_names":linkNames, "unfurl_links":unfurlLinks, "unfurlMedia":unfurlMedia, "username":username, "attachments":encodeAttachments(attachments: attachments), "icon_url":iconURL, "icon_emoji":iconEmoji]
        client.api.request(endpoint: .ChatPostMessage, token: client.token, parameters: filterNilParameters(parameters: parameters), successClosure: {
            (response) -> Void in
                success?((ts: response["ts"] as? String, response["channel"] as? String))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func updateMessage(channel: String, ts: String, message: String, attachments: [Attachment?]? = nil, parse:ParseMode = .None, linkNames: Bool = false, success: ((updated: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["channel": channel, "ts": ts, "text": message.slackFormatEscaping(), "parse": parse.rawValue, "link_names": linkNames, "attachments":encodeAttachments(attachments: attachments)]
        client.api.request(endpoint: .ChatUpdate, token: client.token, parameters: filterNilParameters(parameters: parameters), successClosure: {
            (response) -> Void in
                success?(updated: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    //MARK: - Do Not Disturb
    public func dndInfo(user: String? = nil, success: ((status: DoNotDisturbStatus?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["user": user]
        client.api.request(endpoint: .DNDInfo, token: client.token, parameters: filterNilParameters(parameters: parameters), successClosure: {
            (response) -> Void in
                success?(status: DoNotDisturbStatus(status: response))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func dndTeamInfo(users: [String]? = nil, success: ((statuses: [String: DoNotDisturbStatus]?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["users":users?.joined(separator: ",")]
        client.api.request(endpoint: .DNDTeamInfo, token: client.token, parameters: filterNilParameters(parameters: parameters), successClosure: {
            (response) -> Void in
                success?(statuses: self.enumerateDNDStauses(statuses: response["users"] as? [String: Any]))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    //MARK: - Emoji
    public func emojiList(success: ((emojiList: [String: Any]?)->Void)?, failure: FailureClosure?) {
        client.api.request(endpoint: .EmojiList, token: client.token, parameters: nil, successClosure: {
            (response) -> Void in
                success?(emojiList: response["emoji"] as? [String: Any])
            }) { (error) -> Void in
                failure?(error: error)
        }
    }
    
    //MARK: - Files
    public func deleteFile(fileID: String, success: ((deleted: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["file":fileID]
        client.api.request(endpoint: .FilesDelete, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(deleted: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    //TODO: Currently Unsupported
    /*public func uploadFile(file: NSData, filename: String, filetype: String = "auto", title: String? = nil, initialComment: String? = nil, channels: [String]? = nil, success: ((file: File?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["file":file, "filename": filename, "filetype":filetype, "title":title, "initial_comment":initialComment, "channels":channels?.joined(separator: ",")]
        client.api.uploadRequest(token: client.token, data: file, parameters: filterNilParameters(parameters: parameters), successClosure: {
            (response) -> Void in
                success?(file: File(file: response["file"] as? [String: Any]))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }*/
    
    //MARK: - File Comments
    public func addFileComment(fileID: String, comment: String, success: ((comment: Comment?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["file":fileID, "comment":comment.slackFormatEscaping()]
        client.api.request(endpoint: .FilesCommentsAdd, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(comment: Comment(comment: response["comment"] as? [String: Any]))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func editFileComment(fileID: String, commentID: String, comment: String, success: ((comment: Comment?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["file":fileID, "id":commentID, "comment":comment.slackFormatEscaping()]
        client.api.request(endpoint: .FilesCommentsEdit, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
            success?(comment: Comment(comment: response["comment"] as? [String: Any]))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func deleteFileComment(fileID: String, commentID: String, success: ((deleted: Bool?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["file":fileID, "id": commentID]
        client.api.request(endpoint: .FilesCommentsDelete, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(deleted: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    //MARK: - Groups
    public func closeGroup(groupID: String, success: ((closed: Bool)->Void)?, failure: FailureClosure?) {
        close(endpoint: .GroupsClose, channelID: groupID, success: {
            (closed) -> Void in
                success?(closed:closed)
            }) {(error) -> Void in
                failure?(error:error)
        }
    }
    
    public func groupHistory(id: String, latest: String = "\(Time.slackTimestamp())", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((history: History?)->Void)?, failure: FailureClosure?) {
        history(endpoint: .GroupsHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads, success: {
            (history) -> Void in
                success?(history: history)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func groupInfo(id: String, success: ((channel: Channel?)->Void)?, failure: FailureClosure?) {
        info(endpoint: .GroupsInfo, type:ChannelType.Group, id: id, success: {
            (channel) -> Void in
                success?(channel: channel)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func groupsList(excludeArchived: Bool = false, success: ((channels: [Any]?)->Void)?, failure: FailureClosure?) {
        list(endpoint: .GroupsList, type:ChannelType.Group, excludeArchived: excludeArchived, success: {
            (channels) -> Void in
                success?(channels: channels)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func markGroup(channel: String, timestamp: String, success: ((ts: String)->Void)?, failure: FailureClosure?) {
        mark(endpoint: .GroupsMark, channel: channel, timestamp: timestamp, success: {
            (ts) -> Void in
                success?(ts: timestamp)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func openGroup(channel: String, success: ((opened: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel":channel]
        client.api.request(endpoint: .GroupsOpen, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(opened: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func setGroupPurpose(channel: String, purpose: String, success: ((purposeSet: Bool)->Void)?, failure: FailureClosure?) {
        setInfo(endpoint: .GroupsSetPurpose, type: .Purpose, channel: channel, text: purpose, success: {
            (purposeSet) -> Void in
                success?(purposeSet: purposeSet)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func setGroupTopic(channel: String, topic: String, success: ((topicSet: Bool)->Void)?, failure: FailureClosure?) {
        setInfo(endpoint: .GroupsSetTopic, type: .Topic, channel: channel, text: topic, success: {
            (topicSet) -> Void in
                success?(topicSet: topicSet)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    //MARK: - IM
    public func closeIM(channel: String, success: ((closed: Bool)->Void)?, failure: FailureClosure?) {
        close(endpoint: .IMClose, channelID: channel, success: {
            (closed) -> Void in
                success?(closed: closed)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func imHistory(id: String, latest: String = "\(Time.slackTimestamp())", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((history: History?)->Void)?, failure: FailureClosure?) {
        history(endpoint: .IMHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads, success: {
            (history) -> Void in
                success?(history: history)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func imsList(excludeArchived: Bool = false, success: ((channels: [Any]?)->Void)?, failure: FailureClosure?) {
        list(endpoint: .IMList, type:ChannelType.IM, excludeArchived: excludeArchived, success: {
            (channels) -> Void in
                success?(channels: channels)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func markIM(channel: String, timestamp: String, success: ((ts: String)->Void)?, failure: FailureClosure?) {
        mark(endpoint: .IMMark, channel: channel, timestamp: timestamp, success: {
            (ts) -> Void in
                success?(ts: timestamp)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func openIM(userID: String, success: ((imID: String?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["user":userID]
        client.api.request(endpoint: .IMOpen, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                let group = response["channel"] as? [String: Any]
                success?(imID: group?["id"] as? String)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    //MARK: - MPIM
    public func closeMPIM(channel: String, success: ((closed: Bool)->Void)?, failure: FailureClosure?) {
        close(endpoint: .MPIMClose, channelID: channel, success: {
            (closed) -> Void in
                success?(closed: closed)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func mpimHistory(id: String, latest: String = "\(Time.slackTimestamp())", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((history: History?)->Void)?, failure: FailureClosure?) {
        history(endpoint: .MPIMHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads, success: {
            (history) -> Void in
                success?(history: history)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func mpimsList(excludeArchived: Bool = false, success: ((channels: [Any]?)->Void)?, failure: FailureClosure?) {
        list(endpoint: .MPIMList, type:ChannelType.Group, excludeArchived: excludeArchived, success: {
            (channels) -> Void in
                success?(channels: channels)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func markMPIM(channel: String, timestamp: String, success: ((ts: String)->Void)?, failure: FailureClosure?) {
        mark(endpoint: .MPIMMark, channel: channel, timestamp: timestamp, success: {
            (ts) -> Void in
                success?(ts: timestamp)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func openMPIM(userIDs: [String], success: ((mpimID: String?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["users":userIDs.joined(separator: ",")]
        client.api.request(endpoint: .MPIMOpen, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                let group = response["group"] as? [String: Any]
                success?(mpimID: group?["id"] as? String)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    //MARK: - Pins
    public func pinItem(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, success: ((pinned: Bool)->Void)?, failure: FailureClosure?) {
        pin(endpoint: .PinsAdd, channel: channel, file: file, fileComment: fileComment, timestamp: timestamp, success: {
            (ok) -> Void in
                success?(pinned: ok)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func unpinItem(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, success: ((unpinned: Bool)->Void)?, failure: FailureClosure?) {
        pin(endpoint: .PinsRemove, channel: channel, file: file, fileComment: fileComment, timestamp: timestamp, success: {
            (ok) -> Void in
                success?(unpinned: ok)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    private func pin(endpoint: SlackAPIEndpoint, channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, success: ((ok: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["channel":channel, "file":file, "file_comment":fileComment, "timestamp":timestamp]
        client.api.request(endpoint: endpoint, token: client.token, parameters: filterNilParameters(parameters: parameters), successClosure: {
            (response) -> Void in
                success?(ok: true)
            }){(error) -> Void in
                failure?(error: error)
        }
    }
    
    //MARK: - Reactions
    // One of file, file_comment, or the combination of channel and timestamp must be specified.
    public func addReaction(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((reacted: Bool)->Void)?, failure: FailureClosure?) {
        react(endpoint: .ReactionsAdd, name: name, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp, success: {
            (ok) -> Void in
                success?(reacted: ok)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    // One of file, file_comment, or the combination of channel and timestamp must be specified.
    public func removeReaction(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((unreacted: Bool)->Void)?, failure: FailureClosure?) {
        react(endpoint: .ReactionsRemove, name: name, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp, success: {
            (ok) -> Void in
                success?(unreacted: ok)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    private func react(endpoint: SlackAPIEndpoint, name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((ok: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["name":name, "file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        client.api.request(endpoint: endpoint, token: client.token, parameters: filterNilParameters(parameters: parameters), successClosure: {
            (response) -> Void in
                success?(ok: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    //MARK: - Stars
    // One of file, file_comment, channel, or the combination of channel and timestamp must be specified.
    public func addStar(file: String? = nil, fileComment: String? = nil, channel: String?  = nil, timestamp: String? = nil, success: ((starred: Bool)->Void)?, failure: FailureClosure?) {
        star(endpoint: .StarsAdd, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp, success: {
            (ok) -> Void in
                success?(starred: ok)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    // One of file, file_comment, channel, or the combination of channel and timestamp must be specified.
    public func removeStar(file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: ((unstarred: Bool)->Void)?, failure: FailureClosure?) {
        star(endpoint: .StarsRemove, file: file, fileComment: fileComment, channel: channel, timestamp: timestamp, success: {
            (ok) -> Void in
                success?(unstarred: ok)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    private func star(endpoint: SlackAPIEndpoint, file: String?, fileComment: String?, channel: String?, timestamp: String?, success: ((ok: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any?] = ["file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        client.api.request(endpoint: endpoint, token: client.token, parameters: filterNilParameters(parameters: parameters), successClosure: {
            (response) -> Void in
                success?(ok: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    
    //MARK: - Team
    public func teamInfo(success: ((info: [String: Any]?)->Void)?, failure: FailureClosure?) {
        client.api.request(endpoint: .TeamInfo, token: client.token, parameters: nil, successClosure: {
            (response) -> Void in
                success?(info: response["team"] as? [String: Any])
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    //MARK: - Users
    public func userPresence(user: String, success: ((presence: String?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["user":user]
        client.api.request(endpoint: .UsersGetPresence, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(presence: response["presence"] as? String)
            }){(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func userInfo(id: String, success: ((user: User?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["user":id]
        client.api.request(endpoint: .UsersInfo, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(user: User(user: response["user"] as? [String: Any]))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func usersList(includePresence: Bool = false, success: ((userList: [String: Any]?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["presence":includePresence]
        client.api.request(endpoint: .UsersList, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(userList: response["members"] as? [String: Any])
            }){(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func setUserActive(success: ((success: Bool)->Void)?, failure: FailureClosure?) {
        client.api.request(endpoint: .UsersSetActive, token: client.token, parameters: nil, successClosure: {
            (response) -> Void in
                success?(success: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    public func setUserPresence(presence: Presence, success: ((success: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["presence":presence.rawValue]
        client.api.request(endpoint: .UsersSetPresence, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(success:true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    //MARK: - Channel Utilities
    private func close(endpoint: SlackAPIEndpoint, channelID: String, success: ((closed: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel":channelID]
        client.api.request(endpoint: endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(closed: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    private func history(endpoint: SlackAPIEndpoint, id: String, latest: String = "\(Time.slackTimestamp())", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: ((history: History?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel": id, "latest": latest, "oldest": oldest, "inclusive":inclusive, "count":count, "unreads":unreads]
        client.api.request(endpoint: endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(history: History(history: response))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    private func info(endpoint: SlackAPIEndpoint, type: ChannelType, id: String, success: ((channel: Channel?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel": id]
        client.api.request(endpoint: endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(channel: Channel(channel: response[type.rawValue] as? [String: Any]))
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    private func list(endpoint: SlackAPIEndpoint, type: ChannelType, excludeArchived: Bool = false, success: ((channels: [Any]?)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["exclude_archived": excludeArchived]
        client.api.request(endpoint: endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(channels: response[type.rawValue+"s"] as? [Any])
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    private func mark(endpoint: SlackAPIEndpoint, channel: String, timestamp: String, success: ((ts: String)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel": channel, "ts": timestamp]
        client.api.request(endpoint: endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(ts: timestamp)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }
    
    private func setInfo(endpoint: SlackAPIEndpoint, type: InfoType, channel: String, text: String, success: ((success: Bool)->Void)?, failure: FailureClosure?) {
        let parameters: [String: Any] = ["channel": channel, type.rawValue: text]
        client.api.request(endpoint: endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success?(success: true)
            }) {(error) -> Void in
                failure?(error: error)
        }
    }

    //MARK: - Filter Nil Parameters
    private func filterNilParameters(parameters: [String: Any?]) -> [String: Any] {
        var finalParameters = [String: Any]()
        for key in parameters.keys {
            if parameters[key] != nil {
                finalParameters[key] = parameters[key]!
            }
        }
        return finalParameters
    }
    
    //MARK: - Encode Attachments
    private func encodeAttachments(attachments: [Attachment?]?) -> String? {
        if let attachments = attachments {
            var attachmentArray: [Any] = []
            for attachment in attachments {
                if let attachment = attachment {
                    attachmentArray.append(attachment.dictionary())
                }
            }
            do {
                let string = try Jay().dataFromJson(attachmentArray).string()
                return string
            } catch _ {
                
            }
        }
        return nil
    }
    
    //MARK: - Enumerate Do Not Distrub Status
    private func enumerateDNDStauses(statuses: [String: Any]?) -> [String: DoNotDisturbStatus] {
        var retVal = [String: DoNotDisturbStatus]()
        if let keys = statuses?.keys {
            for key in keys {
                retVal[key] = DoNotDisturbStatus(status: statuses?[key] as? [String: Any])
            }
        }
        return retVal
    }
    
}
