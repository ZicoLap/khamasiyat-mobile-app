import 'package:khamasiyat_mobile_app/l10n/generated/app_localizations.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

extension PitchTypeL10n on PitchType {
  String label(AppLocalizations l10n) {
    switch (this) {
      case PitchType.fiveASide:
        return l10n.pitchTypeFiveASide;
      case PitchType.sevenASide:
        return l10n.pitchTypeSevenASide;
      case PitchType.elevenASide:
        return l10n.pitchTypeElevenASide;
      case PitchType.other:
        return l10n.pitchTypeOther;
    }
  }
}

extension SudanStateL10n on SudanState {
  String label(AppLocalizations l10n) {
    switch (this) {
      case SudanState.khartoum:
        return l10n.stateKhartoum;
      case SudanState.northern:
        return l10n.stateNorthern;
      case SudanState.riverNile:
        return l10n.stateRiverNile;
      case SudanState.redSea:
        return l10n.stateRedSea;
      case SudanState.kassala:
        return l10n.stateKassala;
      case SudanState.gedaref:
        return l10n.stateGedaref;
      case SudanState.gezira:
        return l10n.stateGezira;
      case SudanState.whiteNile:
        return l10n.stateWhiteNile;
      case SudanState.blueNile:
        return l10n.stateBlueNile;
      case SudanState.sennar:
        return l10n.stateSennar;
      case SudanState.northKordofan:
        return l10n.stateNorthKordofan;
      case SudanState.southKordofan:
        return l10n.stateSouthKordofan;
      case SudanState.westKordofan:
        return l10n.stateWestKordofan;
      case SudanState.northDarfur:
        return l10n.stateNorthDarfur;
      case SudanState.southDarfur:
        return l10n.stateSouthDarfur;
      case SudanState.eastDarfur:
        return l10n.stateEastDarfur;
      case SudanState.westDarfur:
        return l10n.stateWestDarfur;
      case SudanState.centralDarfur:
        return l10n.stateCentralDarfur;
    }
  }
}

extension SudanCityL10n on SudanCity {
  String label(AppLocalizations l10n) {
    switch (this) {
      case SudanCity.khartoumCity:
        return l10n.cityKhartoumCity;
      case SudanCity.omdurman:
        return l10n.cityOmdurman;
      case SudanCity.bahri:
        return l10n.cityBahri;
      case SudanCity.dongola:
        return l10n.cityDongola;
      case SudanCity.karima:
        return l10n.cityKarima;
      case SudanCity.wadiHalfa:
        return l10n.cityWadiHalfa;
      case SudanCity.atbara:
        return l10n.cityAtbara;
      case SudanCity.edDamer:
        return l10n.cityEdDamer;
      case SudanCity.shendi:
        return l10n.cityShendi;
      case SudanCity.berber:
        return l10n.cityBerber;
      case SudanCity.portSudan:
        return l10n.cityPortSudan;
      case SudanCity.suakin:
        return l10n.citySuakin;
      case SudanCity.tokar:
        return l10n.cityTokar;
      case SudanCity.kassalaCity:
        return l10n.cityKassalaCity;
      case SudanCity.newHalfa:
        return l10n.cityNewHalfa;
      case SudanCity.gedarefCity:
        return l10n.cityGedarefCity;
      case SudanCity.showak:
        return l10n.cityShowak;
      case SudanCity.wadMadani:
        return l10n.cityWadMadani;
      case SudanCity.hasahisa:
        return l10n.cityHasahisa;
      case SudanCity.kamlin:
        return l10n.cityKamlin;
      case SudanCity.manaqil:
        return l10n.cityManaqil;
      case SudanCity.rabak:
        return l10n.cityRabak;
      case SudanCity.kosti:
        return l10n.cityKosti;
      case SudanCity.edDueim:
        return l10n.cityEdDueim;
      case SudanCity.damazin:
        return l10n.cityDamazin;
      case SudanCity.roseires:
        return l10n.cityRoseires;
      case SudanCity.sinnarCity:
        return l10n.citySinnarCity;
      case SudanCity.singa:
        return l10n.citySinga;
      case SudanCity.elObeid:
        return l10n.cityElObeid;
      case SudanCity.umRawaba:
        return l10n.cityUmRawaba;
      case SudanCity.kadugli:
        return l10n.cityKadugli;
      case SudanCity.abuJubaiha:
        return l10n.cityAbuJubaiha;
      case SudanCity.alFula:
        return l10n.cityAlFula;
      case SudanCity.anNuhud:
        return l10n.cityAnNuhud;
      case SudanCity.elFasher:
        return l10n.cityElFasher;
      case SudanCity.kutum:
        return l10n.cityKutum;
      case SudanCity.nyala:
        return l10n.cityNyala;
      case SudanCity.kass:
        return l10n.cityKass;
      case SudanCity.edDaein:
        return l10n.cityEdDaein;
      case SudanCity.geneina:
        return l10n.cityGeneina;
      case SudanCity.zalingei:
        return l10n.cityZalingei;
    }
  }
}
