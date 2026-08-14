/// Backend `PitchType` enum values for public catalog filters.
enum PitchType {
  fiveASide('FIVE_A_SIDE'),
  sevenASide('SEVEN_A_SIDE'),
  elevenASide('ELEVEN_A_SIDE'),
  other('OTHER');

  const PitchType(this.apiValue);

  final String apiValue;

  static PitchType fromApi(String value) {
    return PitchType.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => throw FormatException('Unknown PitchType: $value'),
    );
  }
}

/// Backend `SudanState` enum.
enum SudanState {
  khartoum('KHARTOUM'),
  northern('NORTHERN'),
  riverNile('RIVER_NILE'),
  redSea('RED_SEA'),
  kassala('KASSALA'),
  gedaref('GEDAREF'),
  gezira('GEZIRA'),
  whiteNile('WHITE_NILE'),
  blueNile('BLUE_NILE'),
  sennar('SENNAR'),
  northKordofan('NORTH_KORDOFAN'),
  southKordofan('SOUTH_KORDOFAN'),
  westKordofan('WEST_KORDOFAN'),
  northDarfur('NORTH_DARFUR'),
  southDarfur('SOUTH_DARFUR'),
  eastDarfur('EAST_DARFUR'),
  westDarfur('WEST_DARFUR'),
  centralDarfur('CENTRAL_DARFUR');

  const SudanState(this.apiValue);

  final String apiValue;

  static SudanState fromApi(String value) {
    return SudanState.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => throw FormatException('Unknown SudanState: $value'),
    );
  }
}

/// Backend `SudanCity` enum (curated majors).
enum SudanCity {
  khartoumCity('KHARTOUM_CITY'),
  omdurman('OMDURMAN'),
  bahri('BAHRI'),
  dongola('DONGOLA'),
  karima('KARIMA'),
  wadiHalfa('WADI_HALFA'),
  atbara('ATBARA'),
  edDamer('ED_DAMER'),
  shendi('SHENDI'),
  berber('BERBER'),
  portSudan('PORT_SUDAN'),
  suakin('SUAKIN'),
  tokar('TOKAR'),
  kassalaCity('KASSALA_CITY'),
  newHalfa('NEW_HALFA'),
  gedarefCity('GEDAREF_CITY'),
  showak('SHOWAK'),
  wadMadani('WAD_MADANI'),
  hasahisa('HASAHISA'),
  kamlin('KAMLIN'),
  manaqil('MANAQIL'),
  rabak('RABAK'),
  kosti('KOSTI'),
  edDueim('ED_DUEIM'),
  damazin('DAMAZIN'),
  roseires('ROSEIRES'),
  sinnarCity('SINNAR_CITY'),
  singa('SINGA'),
  elObeid('EL_OBEID'),
  umRawaba('UM_RAWABA'),
  kadugli('KADUGLI'),
  abuJubaiha('ABU_JUBAIHA'),
  alFula('AL_FULA'),
  anNuhud('AN_NUHUD'),
  elFasher('EL_FASHER'),
  kutum('KUTUM'),
  nyala('NYALA'),
  kass('KASS'),
  edDaein('ED_DAEIN'),
  geneina('GENEINA'),
  zalingei('ZALINGEI');

  const SudanCity(this.apiValue);

  final String apiValue;

  static SudanCity fromApi(String value) {
    return SudanCity.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => throw FormatException('Unknown SudanCity: $value'),
    );
  }
}

/// City → state map matching backend `CITY_TO_STATE`.
abstract final class SudanLocations {
  static const Map<SudanCity, SudanState> cityToState = {
    SudanCity.khartoumCity: SudanState.khartoum,
    SudanCity.omdurman: SudanState.khartoum,
    SudanCity.bahri: SudanState.khartoum,
    SudanCity.dongola: SudanState.northern,
    SudanCity.karima: SudanState.northern,
    SudanCity.wadiHalfa: SudanState.northern,
    SudanCity.atbara: SudanState.riverNile,
    SudanCity.edDamer: SudanState.riverNile,
    SudanCity.shendi: SudanState.riverNile,
    SudanCity.berber: SudanState.riverNile,
    SudanCity.portSudan: SudanState.redSea,
    SudanCity.suakin: SudanState.redSea,
    SudanCity.tokar: SudanState.redSea,
    SudanCity.kassalaCity: SudanState.kassala,
    SudanCity.newHalfa: SudanState.kassala,
    SudanCity.gedarefCity: SudanState.gedaref,
    SudanCity.showak: SudanState.gedaref,
    SudanCity.wadMadani: SudanState.gezira,
    SudanCity.hasahisa: SudanState.gezira,
    SudanCity.kamlin: SudanState.gezira,
    SudanCity.manaqil: SudanState.gezira,
    SudanCity.rabak: SudanState.whiteNile,
    SudanCity.kosti: SudanState.whiteNile,
    SudanCity.edDueim: SudanState.whiteNile,
    SudanCity.damazin: SudanState.blueNile,
    SudanCity.roseires: SudanState.blueNile,
    SudanCity.sinnarCity: SudanState.sennar,
    SudanCity.singa: SudanState.sennar,
    SudanCity.elObeid: SudanState.northKordofan,
    SudanCity.umRawaba: SudanState.northKordofan,
    SudanCity.kadugli: SudanState.southKordofan,
    SudanCity.abuJubaiha: SudanState.southKordofan,
    SudanCity.alFula: SudanState.westKordofan,
    SudanCity.anNuhud: SudanState.westKordofan,
    SudanCity.elFasher: SudanState.northDarfur,
    SudanCity.kutum: SudanState.northDarfur,
    SudanCity.nyala: SudanState.southDarfur,
    SudanCity.kass: SudanState.southDarfur,
    SudanCity.edDaein: SudanState.eastDarfur,
    SudanCity.geneina: SudanState.westDarfur,
    SudanCity.zalingei: SudanState.centralDarfur,
  };

  static bool isCityInState(SudanState state, SudanCity city) {
    return cityToState[city] == state;
  }

  static List<SudanCity> citiesForState(SudanState state) {
    return cityToState.entries
        .where((e) => e.value == state)
        .map((e) => e.key)
        .toList(growable: false);
  }
}
