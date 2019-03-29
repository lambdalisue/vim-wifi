let s:Job = vital#wifi#import('System.Job')

function! s:powershell_update() abort dict
  call self._run_if_not_running()
  if type(self.job) is# v:t_dict && self.job.status() ==# 'run'
    call self.job.send("[Wifi.Vim.Program]::WriteWifiInfo()\n")
  endif
endfunction

function! s:powershell_run_if_not_running() abort dict
  if type(self.job) is# v:t_dict && self.job.status() ==# 'run'
    return
  endif
  let args = [
        \ 'powershell.exe',
        \ '-NoLogo',
        \ '-NonInteractive',
        \ '-NoExit',
        \ '-Command',
        \   '$program = @''' . "\n" .
        \   'using System;' . "\n" .
        \   'using System.Collections.Generic;' . "\n" .
        \   'using System.Runtime.InteropServices;' . "\n" .
        \   'using NET_LUID = System.UInt64;' . "\n" .
        \   'using NET_IFINDEX = System.UInt32;' . "\n" .
        \   'using IFTYPE = System.UInt32;' . "\n" .
        \   '' . "\n" .
        \   'namespace Wifi.Vim' . "\n" .
        \   '{' . "\n" .
        \   '    public class Program' . "\n" .
        \   '    {' . "\n" .
        \   '        static Program()' . "\n" .
        \   '        {' . "\n" .
        \   '            Console.Error.NewLine = "\n";' . "\n" .
        \   '        }' . "\n" .
        \   '        [StructLayout(LayoutKind.Sequential)]' . "\n" .
        \   '        public struct MIB_IPFORWARDROW' . "\n" .
        \   '        {' . "\n" .
        \   '            public uint dwForwardDest;' . "\n" .
        \   '            public uint dwForwardMask;' . "\n" .
        \   '            public uint dwForwardPolicy;' . "\n" .
        \   '            public uint dwForwardNextHop;' . "\n" .
        \   '            public uint dwForwardIfIndex;' . "\n" .
        \   '            public uint dwForwardType;' . "\n" .
        \   '            public uint dwForwardProto;' . "\n" .
        \   '            public uint dwForwardAge;' . "\n" .
        \   '            public uint dwForwardNextHopAS;' . "\n" .
        \   '            public uint dwForwardMetric1;' . "\n" .
        \   '            public uint dwForwardMetric2;' . "\n" .
        \   '            public uint dwForwardMetric3;' . "\n" .
        \   '            public uint dwForwardMetric4;' . "\n" .
        \   '            public uint dwForwardMetric5;' . "\n" .
        \   '        }' . "\n" .
        \   '' . "\n" .
        \   '        [DllImport("Iphlpapi.dll")]' . "\n" .
        \   '        public static extern int GetIpForwardTable(IntPtr table, ref int size, [MarshalAs(UnmanagedType.Bool)]bool order);' . "\n" .
        \   '' . "\n" .
        \   '        public static MIB_IPFORWARDROW[] GetForwardTable()' . "\n" .
        \   '        {' . "\n" .
        \   '            int size = 0;' . "\n" .
        \   '            int err = GetIpForwardTable(IntPtr.Zero, ref size, true);' . "\n" .
        \   '' . "\n" .
        \   '            IntPtr buffer = Marshal.AllocCoTaskMem(size);' . "\n" .
        \   '            err = GetIpForwardTable(buffer, ref size, true);' . "\n" .
        \   '' . "\n" .
        \   '            int count = Marshal.PtrToStructure<int>(buffer);' . "\n" .
        \   '            MIB_IPFORWARDROW[] table = new MIB_IPFORWARDROW[count];' . "\n" .
        \   '            for (int i = 0; i < table.Length; i++)' . "\n" .
        \   '            {' . "\n" .
        \   '                table[i] = Marshal.PtrToStructure<MIB_IPFORWARDROW>(buffer + 4 + Marshal.SizeOf<MIB_IPFORWARDROW>() * i);' . "\n" .
        \   '            }' . "\n" .
        \   '' . "\n" .
        \   '            Marshal.FreeCoTaskMem(buffer);' . "\n" .
        \   '            return table;' . "\n" .
        \   '        }' . "\n" .
        \   '' . "\n" .
        \   '' . "\n" .
        \   '        public const int MAX_ADAPTER_NAME = 128;' . "\n" .
        \   '        public const int IF_MAX_STRING_SIZE = 256;' . "\n" .
        \   '        public const int IF_MAX_PHYS_ADDRESS_LENGTH = 32;' . "\n" .
        \   '        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]' . "\n" .
        \   '        public struct MIB_IF_ROW2' . "\n" .
        \   '        {' . "\n" .
        \   '            public NET_LUID InterfaceLuid;' . "\n" .
        \   '            public NET_IFINDEX InterfaceIndex;' . "\n" .
        \   '            public Guid InterfaceGuid;' . "\n" .
        \   '            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = IF_MAX_STRING_SIZE + 1)]' . "\n" .
        \   '            public string Alias;' . "\n" .
        \   '            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = IF_MAX_STRING_SIZE + 1)]' . "\n" .
        \   '            public string Description;' . "\n" .
        \   '            public int PhysicalAddressLength;' . "\n" .
        \   '            [MarshalAs(UnmanagedType.ByValArray, SizeConst = IF_MAX_PHYS_ADDRESS_LENGTH)]' . "\n" .
        \   '            public byte[] PhysicalAddress;' . "\n" .
        \   '            [MarshalAs(UnmanagedType.ByValArray, SizeConst = IF_MAX_PHYS_ADDRESS_LENGTH)]' . "\n" .
        \   '            public byte[] PermanentPhysicalAddress;' . "\n" .
        \   '            public int Mtu;' . "\n" .
        \   '            public IFTYPE Type;' . "\n" .
        \   '            public int TunnelType;' . "\n" .
        \   '            public int MediaType;' . "\n" .
        \   '            public int PhysicalMediumType;' . "\n" .
        \   '            public int AccessType;' . "\n" .
        \   '            public int DirectionType;' . "\n" .
        \   '            public byte InterfaceAndOperStatusFlags;' . "\n" .
        \   '            public int OperStatus;' . "\n" .
        \   '            public int AdminStatus;' . "\n" .
        \   '            public int MediaConnectState;' . "\n" .
        \   '            public Guid NetworkGuid;' . "\n" .
        \   '            public int ConnectionType;' . "\n" .
        \   '            public long TransmitLinkSpeed;' . "\n" .
        \   '            public long ReceiveLinkSpeed;' . "\n" .
        \   '            public long InOctets;' . "\n" .
        \   '            public long InUcastPkts;' . "\n" .
        \   '            public long InNUcastPkts;' . "\n" .
        \   '            public long InDiscards;' . "\n" .
        \   '            public long InErrors;' . "\n" .
        \   '            public long InUnknownProtos;' . "\n" .
        \   '            public long InUcastOctets;' . "\n" .
        \   '            public long InMulticastOctets;' . "\n" .
        \   '            public long InBroadcastOctets;' . "\n" .
        \   '            public long OutOctets;' . "\n" .
        \   '            public long OutUcastPkts;' . "\n" .
        \   '            public long OutNUcastPkts;' . "\n" .
        \   '            public long OutDiscards;' . "\n" .
        \   '            public long OutErrors;' . "\n" .
        \   '            public long OutUcastOctets;' . "\n" .
        \   '            public long OutMulticastOctets;' . "\n" .
        \   '            public long OutBroadcastOctets;' . "\n" .
        \   '            public long OutQLen;' . "\n" .
        \   '        }' . "\n" .
        \   '' . "\n" .
        \   '        [DllImport("Iphlpapi.dll")]' . "\n" .
        \   '        public static extern int GetIfEntry2(ref MIB_IF_ROW2 Row);' . "\n" .
        \   '        public const int IF_TYPE_IEEE80211 = 71;' . "\n" .
        \   '' . "\n" .
        \   '        [DllImport("Wlanapi.dll")]' . "\n" .
        \   '        public static extern int WlanOpenHandle(int dwClientVersion, IntPtr pReserved, out int pdwNegotiatedVersion, out IntPtr phClientHandle);' . "\n" .
        \   '' . "\n" .
        \   '        [DllImport("Wlanapi.dll")]' . "\n" .
        \   '        public static extern int WlanCloseHandle(IntPtr hClientHandle, IntPtr pReserved);' . "\n" .
        \   '' . "\n" .
        \   '        [DllImport("Wlanapi.dll")]' . "\n" .
        \   '        public static extern void WlanFreeMemory(IntPtr pMemory);' . "\n" .
        \   '' . "\n" .
        \   '        const int WLAN_MAX_NAME_LENGTH = 256;' . "\n" .
        \   '        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]' . "\n" .
        \   '        public struct WLAN_INTERFACE_INFO' . "\n" .
        \   '        {' . "\n" .
        \   '            public Guid InterfaceGuid;' . "\n" .
        \   '            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = WLAN_MAX_NAME_LENGTH)]' . "\n" .
        \   '            public string strInterfaceDescription;' . "\n" .
        \   '            public int isState;' . "\n" .
        \   '        }' . "\n" .
        \   '' . "\n" .
        \   '        [DllImport("Wlanapi.dll")]' . "\n" .
        \   '        public static extern int WlanEnumInterfaces(IntPtr hClientHandle, IntPtr pReserved, out IntPtr ppInterfaceList);' . "\n" .
        \   '        [StructLayout(LayoutKind.Sequential)]' . "\n" .
        \   '        public struct DOT11_SSID' . "\n" .
        \   '        {' . "\n" .
        \   '            int uSSIDLength;' . "\n" .
        \   '            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 32)]' . "\n" .
        \   '            byte[] ucSSID;' . "\n" .
        \   '' . "\n" .
        \   '            public override string ToString()' . "\n" .
        \   '            {' . "\n" .
        \   '                return System.Text.Encoding.UTF8.GetString(ucSSID, 0, uSSIDLength);' . "\n" .
        \   '            }' . "\n" .
        \   '        }' . "\n" .
        \   '        [StructLayout(LayoutKind.Sequential)]' . "\n" .
        \   '        public struct WLAN_ASSOCIATION_ATTRIBUTES' . "\n" .
        \   '        {' . "\n" .
        \   '            public DOT11_SSID dot11Ssid;' . "\n" .
        \   '            public int dot11BssType;' . "\n" .
        \   '            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 6)]' . "\n" .
        \   '            public byte[] dot11Bssid;' . "\n" .
        \   '            public int dot11PhyType;' . "\n" .
        \   '            public int uDot11PhyIndex;' . "\n" .
        \   '            public int wlanSignalQuality;' . "\n" .
        \   '            public int ulRxRate;' . "\n" .
        \   '            public int ulTxRate;' . "\n" .
        \   '        }' . "\n" .
        \   '' . "\n" .
        \   '        [StructLayout(LayoutKind.Sequential)]' . "\n" .
        \   '        public struct WLAN_SECURITY_ATTRIBUTES' . "\n" .
        \   '        {' . "\n" .
        \   '            [MarshalAs(UnmanagedType.Bool)]' . "\n" .
        \   '            public bool bSecurityEnabled;' . "\n" .
        \   '            [MarshalAs(UnmanagedType.Bool)]' . "\n" .
        \   '            public bool bOneXEnabled;' . "\n" .
        \   '            public int dot11AuthAlgorithm;' . "\n" .
        \   '            public int dot11CipherAlgorithm;' . "\n" .
        \   '        }' . "\n" .
        \   '' . "\n" .
        \   '        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]' . "\n" .
        \   '        public struct WLAN_CONNECTION_ATTRIBUTES' . "\n" .
        \   '        {' . "\n" .
        \   '            public int isState;' . "\n" .
        \   '            public int wlanConnectionMode;' . "\n" .
        \   '            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = WLAN_MAX_NAME_LENGTH)]' . "\n" .
        \   '            public string strProfileName;' . "\n" .
        \   '            public WLAN_ASSOCIATION_ATTRIBUTES wlanAssociationAttributes;' . "\n" .
        \   '            public WLAN_SECURITY_ATTRIBUTES wlanSecurityAttributes;' . "\n" .
        \   '        }' . "\n" .
        \   '' . "\n" .
        \   '        [DllImport("Wlanapi.dll")]' . "\n" .
        \   '        public static extern int WlanQueryInterface(IntPtr hClientHandle, ref Guid pInterfaceGuid, int OpCode, IntPtr pReserved, out int pdwDataSize, out IntPtr ppData, IntPtr pWlanOpcodeValueType);' . "\n" .
        \   '        public static void Main()' . "\n" .
        \   '        {' . "\n" .
        \   '            WriteWifiInfo();' . "\n" .
        \   '        }' . "\n" .
        \   '' . "\n" .
        \   '        public static void WriteWifiInfo()' . "\n" .
        \   '        {' . "\n" .
        \   '            int negotiatedVersion;' . "\n" .
        \   '            IntPtr clientHandle;' . "\n" .
        \   '            int err = WlanOpenHandle(2, IntPtr.Zero, out negotiatedVersion, out clientHandle);' . "\n" .
        \   '            if (err != 0)' . "\n" .
        \   '            {' . "\n" .
        \   '                //ERR' . "\n" .
        \   '                return;' . "\n" .
        \   '            }' . "\n" .
        \   '            List<MIB_IPFORWARDROW> interfaces = new List<MIB_IPFORWARDROW>(GetForwardTable());' . "\n" .
        \   '            interfaces.RemoveAll(it => it.dwForwardDest != 0);' . "\n" .
        \   '            interfaces.RemoveAll(it => it.dwForwardMask != 0);' . "\n" .
        \   '            interfaces.Sort((x, y) => Comparer<uint>.Default.Compare(x.dwForwardMetric1, y.dwForwardMetric1));' . "\n" .
        \   '' . "\n" .
        \   '            List<Guid> gateways = new List<Guid>(interfaces.Count);' . "\n" .
        \   '            foreach (MIB_IPFORWARDROW netIf in interfaces)' . "\n" .
        \   '            {' . "\n" .
        \   '                MIB_IF_ROW2 info = GetInterfaceInfo(netIf.dwForwardIfIndex);' . "\n" .
        \   '                if (info.Type != IF_TYPE_IEEE80211) continue;' . "\n" .
        \   '                gateways.Add(info.InterfaceGuid);' . "\n" .
        \   '            }' . "\n" .
        \   '            if (gateways.Count == 0)' . "\n" .
        \   '            {' . "\n" .
        \   '                //NO_WIFI_INTERFACE' . "\n" .
        \   '                Console.Error.WriteLine("s0");' . "\n" .
        \   '                Console.Error.WriteLine("r0");' . "\n" .
        \   '                Console.Error.WriteLine("i");' . "\n" .
        \   '                WlanCloseHandle(clientHandle, IntPtr.Zero);' . "\n" .
        \   '                return;' . "\n" .
        \   '            }' . "\n" .
        \   '            foreach (Guid _guid in gateways)' . "\n" .
        \   '            {' . "\n" .
        \   '                Guid guid = _guid;' . "\n" .
        \   '                int dataSize;' . "\n" .
        \   '                IntPtr ppData;' . "\n" .
        \   '                err = WlanQueryInterface(clientHandle, ref guid, 7, IntPtr.Zero, out dataSize, out ppData, IntPtr.Zero);' . "\n" .
        \   '                    if (err != 0)' . "\n" .
        \   '                    {' . "\n" .
        \   '                        //ERR' . "\n" .
        \   '                        continue;' . "\n" .
        \   '                    }' . "\n" .
        \   '                    WLAN_CONNECTION_ATTRIBUTES attributes = Marshal.PtrToStructure<WLAN_CONNECTION_ATTRIBUTES>(ppData);' . "\n" .
        \   '' . "\n" .
        \   '                    Console.Error.WriteLine("s" + attributes.wlanAssociationAttributes.wlanSignalQuality);' . "\n" .
        \   '                    Console.Error.WriteLine("r" + attributes.wlanAssociationAttributes.ulTxRate / 1000 + " Mbps");' . "\n" .
        \   '                    Console.Error.WriteLine("i" + attributes.wlanAssociationAttributes.dot11Ssid);' . "\n" .
        \   '                    WlanFreeMemory(ppData);' . "\n" .
        \   '                WlanCloseHandle(clientHandle, IntPtr.Zero);' . "\n" .
        \   '                return;' . "\n" .
        \   '            }' . "\n" .
        \   '            Console.Error.WriteLine("s0");' . "\n" .
        \   '            Console.Error.WriteLine("r0");' . "\n" .
        \   '            Console.Error.WriteLine("i");' . "\n" .
        \   '            WlanCloseHandle(clientHandle, IntPtr.Zero);' . "\n" .
        \   '            return;' . "\n" .
        \   '        }' . "\n" .
        \   '        private static MIB_IF_ROW2 GetInterfaceInfo(uint interfaceIndex)' . "\n" .
        \   '        {' . "\n" .
        \   '            MIB_IF_ROW2 row = new MIB_IF_ROW2()' . "\n" .
        \   '            {' . "\n" .
        \   '                InterfaceIndex = interfaceIndex' . "\n" .
        \   '            };' . "\n" .
        \   '            int result = GetIfEntry2(ref row);' . "\n" .
        \   '            return row;' . "\n" .
        \   '        }' . "\n" .
        \   '    }' . "\n" .
        \   '}' . "\n" .
        \   '''@;' .
        \   '',
        \]
  let buffer = ['']
  let self.job = s:Job.start(args, {
        \ 'on_stderr': funcref('s:on_stderr', [buffer], self),
        \})
  if type(self.job) is# v:t_dict && self.job.status() ==# 'run'
    call self.job.send("Add-Type -TypeDefinition $program -Language CSharp\n")
  endif
endfunction

function! s:on_stderr(buffer, data) abort dict
  for line in remove(a:data, 0, -1)
    let key = line[0]
    let value = line[1:]
    if key ==# 'i'
      let self.ssid = value
    elseif key ==# 's'
      " Ref: WLAN_ASSOCIATION_ATTRIBUTES structure (https://docs.microsoft.com/en-us/windows/desktop/api/wlanapi/ns-wlanapi-_wlan_association_attributes)
      let self.rssi = float2nr(str2float(matchstr(value, '\d\+')) / 2 - 100)
    elseif key ==# 'r'
      let self.rate = str2nr(value)
    endif
  endfor
  if type(self.callback) == v:t_func
    call self.callback()
  endif
endfunction

function! wifi#backend#powershell#define() abort
  return {
        \ 'job': 0,
        \ 'rssi': -100,
        \ 'rate': 0,
        \ 'ssid': '',
        \ 'callback': 0,
        \ 'update': funcref('s:powershell_update'),
        \ '_run_if_not_running': funcref('s:powershell_run_if_not_running'),
        \}
endfunction



