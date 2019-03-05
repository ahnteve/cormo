// tslint:disable:no-unused-expression variable-name max-classes-per-file

import * as cormo from '../..';

export class UserRef extends cormo.BaseModel {
  public name?: string | null;

  public age?: number | null;
}

export class UserExtraRef extends cormo.BaseModel {
  public user_id?: number;

  public phone_number?: string | null;
}

export type UserRefVO = cormo.ModelValueObject<UserRef>;
