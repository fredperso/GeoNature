import { Component, OnInit } from '@angular/core';
import { AppConfig } from '../../../conf/app.config';
import { AuthService } from '../auth/auth.service';
import { Router } from '@angular/router';
import { Location } from '@angular/common';
import { HttpClient, HttpParams } from '@angular/common/http';



@Component({
  selector: 'pnx-login',
  templateUrl: 'login.component.html'
})

export class LoginComponent implements OnInit {
  public casLogin: boolean;
  constructor(private _authService: AuthService, private _router: Router, private _location: Location,
  private _http: HttpClient) {
    this.casLogin = AppConfig.CAS.CAS_AUTHENTIFICATION;
   }

    ngOnInit() {
       if (AppConfig.CAS.CAS_AUTHENTIFICATION) {
         // if token not here here, redirection to CAS login page
         if (!this._authService.getToken()) {
          const url_redirection_cas = `${AppConfig.CAS.CAS_LOGIN_URL}?service=${AppConfig.API_ENDPOINT}test_auth/login_cas`;
           document.location.href = url_redirection_cas;
         }
       }

   }
  register(user) {
    this._authService.fakeSigninUser(user.username, user.password);

  }
}

