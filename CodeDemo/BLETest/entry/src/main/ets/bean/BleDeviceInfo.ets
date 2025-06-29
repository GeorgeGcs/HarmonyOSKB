import { ble } from "@kit.ConnectivityKit";

export class BleDeviceInfo {
  public DeviceData: ble.ScanResult | undefined = undefined;
  public advFlags: number = -1;
  public txPowerLevel: number = -1;
  public localName: string = "";
  public serviceUuids: string[] = [];
  public serviceSolicitationUuids: string[] = [];
  public serviceDatas: Record<string, Uint8Array> = {};
  public manufactureSpecificDatas: Record<number, Uint8Array> = {};
  public curPos = 0;
}