local Public = require 'utils.role.main'

local groups = Public.add_groups()

groups['Admin']:edit('allow',false,{
    ['polls']=true,
    ['global-chat']=true,
    ['set-home']=true,
    ['home']=true,
    ['return']=true,
})

groups['Root']:add_role{
    name='Owner',
    short_hand='Owner',
    tag='',
    time=nil,
    colour={r=170,g=0,b=0},
    disallow={},
    is_admin = true,
    is_spectator=true,
    base_afk_time=false
}
groups['Admin']:add_role{
    name='Moderator',
    short_hand='Mod',
    tag='',
    colour={r=0,g=170,b=0},
    disallow={},
    is_admin = true,
    is_spectator=true,
    base_afk_time=false
}

local roles = Public.add_roles()

roles['Owner']:edit('allow',false,{
    ['game-settings']=true,
    ['always-warp']=true,
    ['admin-items']=true,
    ['admin-commands']=true,
    ['interface'] = true,
    ['warp-list']=true,
    ['repair']=true,
})

Public.standard_roles{
    ['gerkiz']='Owner'
}

return Public