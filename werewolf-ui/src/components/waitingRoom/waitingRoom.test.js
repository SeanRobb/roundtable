import React from './node_modules/react';
import { render, screen } from './node_modules/@testing-library/react';
import './node_modules/@testing-library/jest-dom/extend-expect';
import WaitingRoom from './waitingRoom';

describe('<WaitingRoom />', () => {
  test('it should mount', () => {
    render(<WaitingRoom />);
    
    const waitingRoom = screen.getByTestId('WaitingRoom');

    expect(waitingRoom).toBeInTheDocument();
  });
});