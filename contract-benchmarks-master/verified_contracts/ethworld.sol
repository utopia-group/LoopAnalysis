pragma solidity ^0.4.18;

/*
项目：“企业金链”智能合约，客户案例
时间：2018-03-20
 */

contract ethworld {
    string public ProjectName="亦思教育";
    string public ProjectTag="企业金链";  //行业金链,企业金链,媒体金链

    string public Descript="官网：tjiace.com 地址:天津市和平区南京路181号天津世纪都会写字楼1505室 电话:022-27371166 E-mail：<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="dbb2b5bdb49bafb1b2bab8bef5b8b4b6">[email protected]</a> 亦思创艺教育（International Academy of Creative Education, IACE）, 初创于英国，是一所被英国创意艺术大学(UCA)及英国伯明翰艺术设计学院(BCU)等多个世界著名艺术设计院校认可的本科、硕士及博士预科培训机构。亦思教育(IACE)与英国各艺术大学的本科，硕士及博士艺术教育课程直接接轨，专注于为有意向赴英修读本科、硕士及博士学位的学生做好留学准备。亦思创艺教育(IACE)开设的国际预科课程，国际化艺术指导、专业作品集培训及留学艺术规划等课程将满足各个专业、不同学生需求。我们致力于提供最优秀的海归及海外艺术导师、教授、设计师及艺术家团队为热爱艺术设计的学生开辟一条崭新的创意之路。";&#13;
    string[] public Images;&#13;
    address public ProjectOwner;&#13;
&#13;
//    event loginfo(address fromaddr,address toaddr,string info);&#13;
    &#13;
    modifier OnlyOwner() { // Modifier&#13;
        require(msg.sender == ProjectOwner);&#13;
        _;&#13;
    }   &#13;
    &#13;
    function ethworld() public {&#13;
        ProjectOwner=msg.sender;&#13;
    }&#13;
    &#13;
    function SetProjectName(string NewProjectName) OnlyOwner public {&#13;
        if(bytes(ProjectName).length==0) ProjectName = NewProjectName;&#13;
    }&#13;
&#13;
    function SetProjectTag(string NewTag) OnlyOwner public {&#13;
        if(bytes(ProjectTag).length==0) ProjectTag = NewTag;&#13;
    }&#13;
    &#13;
    //set description&#13;
    function SetDescript(string NewDescript) OnlyOwner public{ &#13;
        Descript=NewDescript;&#13;
    }&#13;
&#13;
    //insert imagimage&#13;
    function InsertImage(string ImageAddress) OnlyOwner public{&#13;
        Images.push(ImageAddress);&#13;
    }&#13;
        //changeimage&#13;
    function ChangeImage(string ImageAddress,uint index) OnlyOwner public{&#13;
        if(index&lt;Images.length)&#13;
        {&#13;
            Images[index]=ImageAddress;&#13;
        }&#13;
    }&#13;
    &#13;
    //del image&#13;
    function DeleteImage(uint index) OnlyOwner public{&#13;
        if(index&lt;Images.length)&#13;
        {&#13;
            for(uint loopindex=index;loopindex&lt;(Images.length-1);loopindex++)&#13;
            {&#13;
                Images[loopindex]=Images[loopindex+1];&#13;
            }&#13;
            Images.length--;&#13;
        }&#13;
    }&#13;
    &#13;
    //change owner of ethworld content&#13;
    function ChangeOwner(address newowner) OnlyOwner public{&#13;
//        loginfo(owner,newowner,"转移智能合约(DAPP)控制权");&#13;
        ProjectOwner=newowner;&#13;
    }&#13;
&#13;
    //kill this&#13;
    function KillContracts() OnlyOwner public{&#13;
//        loginfo(msg.sender,0,"销毁智能合约(DAPP)");&#13;
        selfdestruct(msg.sender);&#13;
    }&#13;
    &#13;
    &#13;
//the end&#13;
}