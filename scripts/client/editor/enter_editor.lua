local AccountSB = imgui.CreateStrbuf('oceancx',256)
local PasswordSB = imgui.CreateStrbuf('123456',256)

local IPSB = imgui.CreateStrbuf('127.0.0.1',256)
local PortSB = imgui.CreateStrbuf('45000',256)

local PosX = imgui.CreateStrbuf('200',128)
local PosY = imgui.CreateStrbuf('2790',128)
local show_demo = false

local function format_path(path)
    if string.find(path, '@') == 1 then
        path = string.sub(path, 2)
    end
    path = string.gsub(path,'\\','/')
    return string.lower(path)
end

local DebugButtons = {
    {
        name  = 'Sigin Up',
        on_click = function()
            local msg = {}
            msg.account = AccountSB:str()
            msg.password = PasswordSB:str()
            net_send_message(PTO_C2C_SIGNUP, cjson.encode(msg))
        end
    },
    {
        name  = 'Sigin In',
        on_click = function()
            local msg = {}
            msg.account = AccountSB:str()
            msg.password = PasswordSB:str()
            msg.name = 'oceancx'
            msg.scene_id = 1135
            msg.role_id = 1
            msg.weapon_id = 40
            msg.x = 200
            msg.y = 2790
            net_send_message(PTO_C2C_LOGIN, cjson.encode(msg))
        end
    },
    {
        name  = '刷新角色数据库',
        on_click = function()
            local player = actor_manager_fetch_local_player()
            local msg = {}
            msg.pid = player:GetID()
            net_send_message(PTO_C2C_SAVE_PLAYER_DATABASE, cjson.encode(msg))
        end
    },
    {
        name  = '重连服务器',
        on_click = function()
            net_manager_reconnect()
        end
    },

    {
        name  = 'EnterBattle',
        on_click = function()
            scene_manager_switch_scene_by_name('BattleScene')
        end
    },
    {
        name  = '监听调试器',
        on_click = function()
            luadbg_stop()
            luadbg_listen(9527) 
        end
    },
    {
        name  = '启动DebugAdapter',
        on_click = function()
            local path = vfs_makepath('internals/luadebugger/vscode/Debug/vsdbgadapter.exe')
            local cwd = vfs_makepath('internals/luadebugger/vscode/')
            cwd = format_path(cwd) 
            local cmd = string.format('start %s --cwd=%s',path,cwd )
            os.execute(cmd)
        end
    },
    {
        name  = '启动服务器',
        on_click = function()
            local path = vfs_makepath('bin/Debug/SimpleServer.exe')
            local cwd = vfs_makepath('') 
            cwd = format_path(cwd) 
            local cmd = string.format('start %s --cwd=%s',path,cwd )
            os.execute(cmd)
        end
    },
    {
        name  = '安装vscode插件',
        on_click = function()
            local dir = vfs_makepath('')
            local cmd = string.format('sh  %sinternals/luadebugger/install_extension.sh %s',dir,dir)
            print(cmd)
            os.execute(cmd)
        end
    },
    {
        name  = 'Reload',
        on_click = function()
            script_system_dofile('editor/enter_editor.lua')
        end
    },
    {
        name  = 'printEnv',
        on_click = function()
            utils_dump_table(_ENV)
        end
    }
}
     
function on_enter_editor_update()    
    imgui.Begin('Login')
    local res 
    ret, show_demo = imgui.Checkbox('Demo', show_demo)
    if show_demo then
        imgui.ShowDemoWindow(show_demo)
    end
    imgui.Text('IP  :')
    imgui.SameLine()
    imgui.InputText('##IP', IPSB)

    imgui.Text('Port  :')
    imgui.SameLine()
    imgui.InputText('##Port', PortSB)

    if imgui.Button('连接服务器') then
        local ip = IPSB:str()
        local port = math.tointeger(PortSB:str())
        net_manager_deinit()
        net_manager_init(ip, port)
    end

    imgui.Text("Account   :");
	imgui.SameLine();
    imgui.InputText("##account", AccountSB);

    imgui.Text("Password   :");
	imgui.SameLine();
    imgui.InputText("##password", PasswordSB);
        
    imgui.Text("Pos :");
    imgui.SameLine()
    imgui.PushItemWidth(80)
    imgui.InputText("##posX", PosX)
    imgui.SameLine()
    imgui.InputText("##posY", PosY)
    imgui.PopItemWidth()
    
    imgui_std_horizontal_button_layout(DebugButtons,function(t,k) 
        local nk,v = next(t,k)
        return nk,v, nk and t[nk].name
    end,function(k,v)
        v.on_click()
    end)
   
    imgui.End()
end


