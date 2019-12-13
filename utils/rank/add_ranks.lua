local Public = require 'utils.rank.main'

local groups = Public.add_groups(true)

groups['Root']:edit('allow',false,{
    ['player-list']=true,
    ['readme']=true,
    ['rockets']=true,
    ['science']=true,
    ['tasklist']=true,
    ['rank-changer']=true,
    ['admin-commands']=true,
    ['warn']=true,
    ['temp-ban']=true,
    ['clear-warings']=true,
    ['clear-reports']=true,
    ['clear-all']=true,
    ['clear-inv']=true,
    ['announcements']=true,
    ['warp-list']=true,
    ['polls']=true,
    ['admin-items']=true,
    ['all-items']=true,
    ['repair']=true,
    ['global-chat']=true,
    ['set-home']=true,
    ['home']=true,
    ['return']=true,
})
groups['Admin']:edit('allow',false,{
    ['player-list']=true,
    ['readme']=true,
    ['rockets']=true,
    ['science']=true,
    ['tasklist']=true,
    ['rank-changer']=true,
    ['admin-commands']=true,
    ['warn']=true,
    ['temp-ban']=true,
    ['clear-warings']=true,
    ['clear-reports']=true,
    ['clear-all']=true,
    ['clear-inv']=true,
    ['announcements']=true,
    ['warp-list']=true,
    ['polls']=true,
    ['global-chat']=true,
    ['set-home']=true,
    ['home']=true,
    ['return']=true,
})
groups['User']:edit('allow',false,{
    ['player-list']=true,
    ['readme']=true,
    ['rockets']=true,
    ['science']=true,
    ['tasklist']=true,
    ['report']=true,
    ['warp-list']=true,
    ['polls']=true
})
groups['Jail']:edit('allow',false,{
})

groups['Root']:add_rank{
    name='Owner',
    short_hand='Owner',
    tag='[Owner]',
    time=nil,
    colour={r=170,g=0,b=0},
    disallow={},
    is_admin = true,
    is_spectator=true,
    base_afk_time=false
}
groups['Admin']:add_rank{
    name='Mod',
    short_hand='Mod',
    tag='[Mod]',
    colour={r=0,g=170,b=0},
    disallow={},
    is_admin = true,
    is_spectator=true,
    base_afk_time=false
}

groups['User']:add_rank{
    name='Veteran',
    short_hand='Vet',
    tag='[Veteran]',
    time=600,
    power=1,
    colour={r=26,g=118,b=156},
    base_afk_time=60
}

local ranks = Public.add_ranks(true)

ranks['Admin']:edit('allow',false,{
    ['game-settings']=true,
    ['always-warp']=true,
    ['admin-items']=true
})
ranks['Mod']:edit('allow',false,{
    ['go-to']=true,
    ['bring']=true,
    ['no-report']=true
})
ranks['Veteran']:edit('allow',false,{
    ['tree-decon']=true,
    ['create-poll']=true,
    ['repair']=true
})
ranks['Member']:edit('allow',false,{
    ['edit-tasklist']=true,
    ['make-warp']=true,
    ['nuke']=true,
    ['base-damage']=true,
    ['varified']=true,
    ['kill']=true,
    ['decon']=true,
    ['capsules']=true
})

Public.standard_ranks{
    ['gerkiz']='Owner'
}

return Public